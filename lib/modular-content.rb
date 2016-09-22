module Jekyll
  class ModularContent < Jekyll::Tags::IncludeTag
    def parse_module(modules_dir, module_name, page, context, site)
      include_data = Hash.new
      module_path = nil

      if module_name.is_a? String
        module_path = File.join(modules_dir, "#{module_name}.html")
      else
        module_name.select do |file_name, params|
          module_path = File.join(modules_dir, "#{file_name}.html")
          include_data = params
        end
      end

      context['include'] = include_data

      module_html = site.liquid_renderer
        .file(module_path)
        .parse(read_file(module_path, context))
        .render!(context)
      context['include'] = nil

      module_html
    end

    def render(context)
      site = context.registers[:site]
      page_data = context.environments.first['page']
      page = site.pages.detect { |page| page.url == page_data['url']}
      renderer = Jekyll::Renderer.new(site, page, {})

      modules_dir = File.join(site.source, '_includes/modules')
      if site.config['modules']
        modules_dir = File.join(site.source, site.config['modules'])
      end

      return unless page.data['modules']

      html = ''
      page.data['modules'].each do |mod_name|
          html += parse_module(modules_dir, mod_name, page, context, site)
      end

      html
    end
  end
end

Liquid::Template.register_tag('modular_content', Jekyll::ModularContent)
