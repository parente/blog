## -*- coding: utf-8 -*-
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <meta name="robots" content="index,follow">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="proof" content="proven.lol/ac4104">
    <%block name="header">
      <title>${site_name}</title>
    </%block>
    <link rel="alternate" type="application/rss+xml" title="RSS 2.0" href="${site_root}/feed/index.xml" />
    <link rel="alternate" type="application/atom+xml" title="Atom 1.0" href="${site_root}/feed/atom/index.xml" />
    <link rel="stylesheet" type="text/css" href="${site_root}/static/css/pygments.css" />
    <link rel="stylesheet" href='https://fonts.googleapis.com/css?family=Dosis:300,600' type='text/css'>
    <link rel="stylesheet" href='https://fonts.googleapis.com/css?family=Gentium+Basic' type='text/css'>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" integrity="sha384-T3c6CoIi6uLrA9TneNEoa7RxnatzjcDSCmG1MXxSR1GAsXEV/Dwwykc2MPK8M2HN" crossorigin="anonymous">
    <link rel="stylesheet" href="${site_root}/static/css/site.css" type="text/css" />
    <script src="https://kit.fontawesome.com/0affbb0817.js" crossorigin="anonymous"></script>
  </head>
  <body>
    <div class="container">
      <!-- Header -->
      <header id="siteTitle">
        <h1><a href="${site_root}/">${site_name}</a></h1>
        <nav>
          <a href="${site_root}/">Latest</a>
          <a href="${site_root}/posts/">Posts</a>
          <a href="${site_root}/about/">About</a>
        </nav>
      </header>

      <!-- Main Body -->
      <article id="mainColumn">
        <%block name="mainColumn" />
      </article>

      <!-- Page Meta -->
      <%block name="pageMeta" />

      <!-- Site Meta -->
      <div class="row footerSection gx-5" id="siteMeta">

        <div class="col-md-3" id="social">
          <h3>Contact</h3>
          <div>
            <i class="fa-brands fa-bluesky"></i></i> <a href="https://bsky.app/profile/parente.dev">Bluesky</a><br/>
            <i class="fa-brands fa-github"></i> <a href="https://github.com/parente">GitHub</a><br/>
            <i class="fa-brands fa-linkedin"></i> <a href="https://linkedin.com/in/parente">LinkedIn</a><br/>
            <i class="fa-solid fa-rss"></i> <a href="${site_root}/feed/index.xml">RSS</a><br/>
          </div>
        </div>
        <div class="col-md-9" id="latest">
          <h3>Latest Posts</h3>
          <ul class="archiveList">
          % for recent in all_pages[:3]:
            <li><span class="date">${recent['date'].strftime('%Y-%m-%d')}</span> &mdash; <a href="${site_root}/${recent['slug']}">${recent['title']}</a></li>
          % endfor
            <li><a href="${site_root}/posts/">See all posts &#187;</a></li>
          </ul>
        </div>
      </div>

      <!-- Footer -->
      <footer id="siteFooter" class="footerSection">
        <p class="footerText">Copyright &copy; 2008, 2024 Peter Parente. All rights reserved. Except for materials otherwise noted. </p>
      </footer>
    </div>
  </body>
</html>