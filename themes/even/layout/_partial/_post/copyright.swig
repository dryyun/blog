{# Post Copyright #}
{% if theme.copyright.enable and page.copyright !== false %}
  <div class="post-copyright">
  <blockquote>
    <p class="copyright-item">
      <span>{{ __('copyright.author') + ': ' }}</span>
      <a href="{{ config.url }}">{{ config.author }}</a>
    </p>
    <p class="copyright-item">
      <span>{{ __('copyright.link') + ': ' }}</span>
      <a href="{{ page.permalink }}">{{ page.permalink }}</a>
    </p>
    <p class="copyright-item">
      <span>{{ __('copyright.date') + ': ' }}</span>
      {{ date(page.date, 'YYYY-MM-DD HH:mm') }}
    </p>
    <p class="copyright-item">
      <span>{{ __('copyright.license') + ': ' }}</span>
      {% set license = page.license || theme.copyright.license %}
      {{ license }}
    </p>
  </blockquote>
  </div>
{% endif %}
