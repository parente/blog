## -*- coding: utf-8 -*-
<?xml version="1.0" encoding="UTF-8"?><% from datetime import datetime, UTC %>
<rss version="2.0"
     xmlns:content="http://purl.org/rss/1.0/modules/content/"
     xmlns:sy="http://purl.org/rss/1.0/modules/syndication/"
     xmlns:atom="http://www.w3.org/2005/Atom"
     >
  <channel>
    <title>${site_name}</title>
    <link>${site_domain}</link>
    <description>Blog of Peter Parente</description>
    <pubDate>${datetime.now(UTC).strftime("%a, %d %b %Y %H:%M:%S GMT")}</pubDate>
    <generator>https://github.com/parente/blog</generator>
    <sy:updatePeriod>daily</sy:updatePeriod>
    <sy:updateFrequency>1</sy:updateFrequency>
    <atom:link href="${site_domain}/rss.xml" rel="self" type="application/rss+xml" />
% for page in latest_pages:
    <item>
      <title>${page['title']}</title>
      <link>${site_domain}${site_root}/${page['slug']}/</link>
      <pubDate>${page['date'].strftime("%a, %d %b %Y %H:%M:%S GMT")}</pubDate>
      <guid>${site_domain}${site_root}/${page['slug']}/</guid>
      <description>${page['title']}</description>
      <content:encoded><![CDATA[${page['excerpt']}]]></content:encoded>
    </item>
% endfor
  </channel>
</rss>
