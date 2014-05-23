=begin
    Copyright 2010-2014 Tasos Laskos <tasos.laskos@gmail.com>
    All rights reserved.
=end

module Arachni
module Element

# @author Tasos "Zapotek" Laskos <tasos.laskos@gmail.com>
module Capabilities::Submittable

    def initialize( options )
        super
        self.action = options[:action] || self.url
        self.method = options[:method] || :get
    end

    # @return   [Platform]
    #   Applicable platforms for the {#action} resource.
    def platforms
        Platform::Manager[@action]
    end

    # Should represent a method in {Arachni::Check::HTTP}.
    #
    # Ex. get, post, cookie, header
    #
    # @see Arachni::Check::HTTP
    #
    # @return [Symbol]  HTTP request method for the element.
    def method( *args )
        return super( *args ) if args.any?
        @method.freeze
    end

    # @see #method
    def method=( method )
        @method = method.to_s.downcase.to_sym
    end

    # @note Ex. 'href' for links, 'action' for forms, etc.
    #
    # @return  [String]
    #   URI to which the element points and should be audited against.
    def action
        @action.freeze
    end

    # @see #action
    def action=( url )
        @action = self.url ? to_absolute( url, self.url ) : normalize_url( url )
    end

    # @note Sets `self` as the {HTTP::Request#performer}.
    #
    # Submits `self` to the {#action} URL with the appropriate
    # {Capabilities::Inputtable#inputs parameters}.
    #
    # @param  [Hash]  options
    # @param  [Block]  block    Callback to be passed the {HTTP::Response}.
    #
    # @see #http_request
    def submit( options = {}, &block )
        options                   = options.dup
        options[:parameters]      = @inputs.dup
        options[:follow_location] = true if !options.include?( :follow_location )

        @auditor ||= options.delete( :auditor )

        options[:performer] = self
        http_request( options, &block )
    end

    # Must be implemented by the including class and perform the appropriate
    # HTTP request (get/post/whatever) for the current element.
    #
    # Invoked by {#submit} to submit the object.
    #
    # @param    [Hash]      opts
    # @param    [Block]     block    Callback to be passed the HTTP response.
    #
    # @return   [HTTP::Request]
    #
    # @see #submit
    # @abstract
    def http_request( opts, &block )
        fail NotImplementedError
    end

    # @return   [Arachni::HTTP]
    def http
        HTTP::Client
    end

    def ==( e )
        hash == e.hash
    end
    alias :eql? :==

    def hash
        "#{type}:#{action}:#{method}:#{inputs.hash}}".hash
    end

    def dup
        new = super
        new.action = self.action
        new.method = self.method
        new
    end

    def to_h
        (defined?( super ) ? super : {}).merge(
            url:    url,
            action: action,
            method: method
        )
    end

end
end
end
