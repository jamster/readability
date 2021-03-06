module Readability
  module Readable
    include Readability::Harmonizable

    def read_style
      @read_style ||= Readability::Style::NEWSPAPER
    end
    
    def read_size
      @read_size ||= Readability::Size::MEDIUM
    end
    
    def read_margin
      @read_margin ||= Readability::Margin::MEDIUM
    end

    attr_writer :read_style, :read_size, :read_margin
    
    def unlink(*paths)
      self.search(*paths).unlink
    end
    
    alias :remove :unlink
    
    def to_readable(args = {})
      # dup document
      readable_doc = self.dup
      
      # remove all script and iframe tags
      readable_doc.remove('script')
      readable_doc.remove('iframe')
      
      readable_doc.harmony_page do |page|
        # Set parameters
        page.window.readStyle = @read_style
        page.window.readSize = @read_size
        page.window.readMargin = @read_margin
        
        # execute readability.js
        page.load(File.join(File.dirname(__FILE__), 'js', 'readability.js'))
      end
      
      # remove all linebreaks if needed
      readable_doc.remove('br') if args[:remove_br]
      
      # remove footer if needed
      readable_doc.remove('#readFooter') if args[:remove_footer]
      
      # return <div id="readInner">...</div> if content_only
      if args[:content_only]
        return readable_doc.at_css("#readInner")
      end
      
      # return document root
      readable_doc.root
    end
    
    def to_readable!(args = {})
      self.root = to_readable(args)
    end
  end
end