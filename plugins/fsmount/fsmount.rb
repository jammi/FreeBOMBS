
require 'cgi'
class FSMount < Servlet

  def open
    @mounts = {}
    @info[:config][:mount].each do |mountpoint,directory|
      data_path = File.expand_path( directory, @path )
      @mounts[ mountpoint ] = data_path
    end
    @time_modified = Time.at(0).gmtime.strftime('%a, %d %b %Y %H:%M:%S %Z')
    @time_expires  = Time.mktime(2030,1,1).gmtime.strftime('%a, %d %b %Y %H:%M:%S %Z')
    mime_src = file_read( 'mime.types' )
    @mime_by_ext = {}
    mime_src.split("\n").each do |mime_ln|
      mime_ln.strip!
      next if mime_ln == ''
      next if mime_ln.start_with?( '#' )
      mime_split = mime_ln.split
      next if mime_split.length == 1
      content_type = mime_split.first
      mime_split[1..-1].each do |ext|
        ext = ".#{ext}"
        @mime_by_ext[ext] = content_type
      end
    end
  end

  def uri_matches?(uri)
    uri = uri.split('?').first if uri.include?('?')
    @mounts.each_key do |uri_prefix|
      return true if uri.start_with?( uri_prefix )
    end
    return false
  end
  
  def uri_to_path(uri)
    @mounts.each_key do |uri_prefix|
      if uri.start_with?( uri_prefix )
        root_path = @mounts[uri_prefix]
        rel_path = uri[uri_prefix.bytesize..-1]
        full_path = File.expand_path(File.join(root_path,rel_path))
        return full_path
      end
    end
  end
  
  def mime_type( file_path )
    path_split = file_path.split('.')
    return "text/plain" if path_split.length == 1
    file_ext = ".#{path_split[-1]}"
    return "text/plain" unless @mime_by_ext.has_key?( file_ext )
    return @mime_by_ext[file_ext]
  end
  
  def error_404(res)
    res.status = 404
    res['Content-Type'] = 'text/plain'
    res.body = '404 - Not Found'
  end
  
  def match( uri, request_type) 
    return (request_type == :get and uri_matches?(uri))
  end
  
  def html_index(full_path, res, uri)
    res.status = 200
    res['Content-Type'] = 'text/html; charset=UTF-8'
    directories = Dir.entries(full_path)
    directoryhtml = ''
    directories.each do |dir|
      directoryhtml += %{<li><a href="#{File.join(uri,CGI.escape(dir))}">#{dir}</a></li>}
    end
    res.body = "<html><head><title>Index of #{uri}</title></head><body><ul>#{directoryhtml}</ul></body><html>"
  end
  
  def serve_file(full_path, res)
    begin
      res.status = 200
      res['Content-Type'] = mime_type( full_path )
      content = File.read(full_path)
      res['Expires'] = @time_expires
      res['Last-Modified'] = @time_modified
      res['Content-Length'] = content.bytesize
      res.body = content
    rescue
      res.status = 503
      res['Content-Type'] = 'text/plain'
      res.body = '503 - Generic Server Error'
    end
  end
  
  def get( req, res, ses)
    uri = CGI.unescape(req.fullpath)
    uri = uri.split('?').first if uri.include?('?')
    unless uri_matches?(uri)
      error_404(res)
      return
    end
    full_path = uri_to_path(uri)
    unless File.exist?(full_path)
      error_404(res)
      return
    end
    if File.directory?(full_path)
      html_index(full_path, res, uri)
    else
      serve_file(full_path, res)
    end
  end
  
end

