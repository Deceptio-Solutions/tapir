
require 'socket'
require 'openssl'

def name
  "gather_ssl_certificate"
end

def pretty_name
  "Gather SSL Certificate"
end

def authors
  ['jcran']
end

## Returns a string which describes what this task does
def description
  "This task allows you to gather an SSL Certificate."
end

## Returns an array of types that are allowed to call this task
def allowed_types
  [ Entities::NetSvc, 
    Entities::WebApplication ]
end

## Returns an array of valid options and their description/type for this task
def allowed_options
end

def setup(entity, options={})
  super(entity, options)
end

## Default method, subclasses must override this
def run
  super

  # Determine which type of entity we're working with
  if @entity.class == Entities::NetSvc
    hostname = @entity.host.name
    port = @entity.port_num
  else
    # if it's a web application
    hostname = @entity.host.name
    # Check to see if there's an associated service first
    if @entity.netsvc
      port = @entity.netsvc.port_num 
    else
      # default to 443
      port = 443
    end
  end

  begin
    # Create a socket and connect
    tcp_client = TCPSocket.new hostname, port
    ssl_client = OpenSSL::SSL::SSLSocket.new tcp_client
    
    # Grab the cert
    ssl_client.connect

    # Parse the cert
    cert = OpenSSL::X509::Certificate.new(ssl_client.peer_cert)

    # Check the subjectAltName property, and if we have names, here, parse them.
    cert.extensions.each do |ext|
      if ext.oid =~ /subjectAltName/

        alt_names = ext.value.split(",").collect do |x|
          x.gsub(/DNS:/,"").strip
        end

        alt_names.each do |alt_name|
          create_entity Entities::DnsRecord, { :name => alt_name }
        end

      end
    end

    # Close the sockets
    ssl_client.sysclose
    tcp_client.close

    # Create an SSL Certificate entity
    create_entity Entities::SslCert, { :name => cert.subject,
                                       :text => cert.to_text }
  rescue OpenSSL::SSL::SSLError => e
    @task_logger.error "Caught an error: #{e}"
  rescue Errno::ECONNRESET => e 
    @task_logger.error "Caught an error: #{e}"
  rescue RuntimeError => e 
    @task_logger.error "Caught an error: #{e}"
  end
  
end

def cleanup
  super
end
