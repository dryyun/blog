{%- if theme.disqus_shortname -%}
  <script type="text/javascript">
    var disqus_config = function () {
        this.page.title = '{{ page.title }}';
        {%- if page.disqusUrl -%}
            this.page.url = '{{config.url}}{{page.disqusUrl}}';
        {%- else -%}
        this.page.url = '{{ page.permalink }}';
        {%- endif -%}

    };
    (function() {
    var d = document, s = d.createElement('script');

    s.src = '//{{theme.disqus_shortname}}.disqus.com/embed.js';

    s.setAttribute('data-timestamp', +new Date());
    (d.head || d.body).appendChild(s);
    })();  
  </script>
{%- endif -%}