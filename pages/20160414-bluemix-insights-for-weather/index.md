---
title: Kicking the Tires: Bluemix Insights for Weather
date: 2016-04-14
excerpt: In this notebook, we're going to poke at the <a href="https://new-console.ng.bluemix.net/docs/services/Weather/index.html#weather">Bluemix Insights for Weather service</a> from Python. We'll look at what kinds of queries we can make and do a few basic things with the data. We'll keep a running commentary that can serve as an introductory tutorial for developers who want to go off and build more sophisticated apps and analyses using the service.
author_comment: This post comes from a <a href="https://gist.github.com/parente/9ed8ae67705a44522fde767e5cd7d553">Jupyter notebook I wrote</a> to help a colleague learn how to access a Bluemix service from Python. Along the way, I learned about <code>pandas.io.json.json_normalize</code> and how great it is at turning nested JSON structures into flatter DataFrames. (It deserves a short post of its own.)
template: notebook.mako
---

<div class="cell border-box-sizing text_cell rendered"><div class="prompt input_prompt">
</div><div class="inner_cell">
<div class="text_cell_render border-box-sizing rendered_html">
<p>In this notebook, we're going to poke at the <a href="https://new-console.ng.bluemix.net/docs/services/Weather/index.html#weather">Bluemix Insights for Weather service</a> from Python. We'll look at what kinds of queries we can make and do a few basic things with the data. We'll keep a running commentary that can serve as an introductory tutorial for developers who want to go off and build more sophisticated apps and analyses using the service.</p>

</div>
</div>
</div>
<div class="cell border-box-sizing text_cell rendered"><div class="prompt input_prompt">
</div><div class="inner_cell">
<div class="text_cell_render border-box-sizing rendered_html">
<h2 id="Get-some-handy-libs">Get some handy libs<a class="anchor-link" href="#Get-some-handy-libs">&#182;</a></h2>
</div>
</div>
</div>
<div class="cell border-box-sizing text_cell rendered"><div class="prompt input_prompt">
</div><div class="inner_cell">
<div class="text_cell_render border-box-sizing rendered_html">
<p>Let's start by getting some handy Python libraries for making HTTP requests and looking at the data. You can install these with typical Python package management tools like <code>pip install &lt;name&gt;</code> or <code>conda install &lt;name&gt;</code>.</p>

</div>
</div>
</div>
<div class="cell border-box-sizing code_cell rendered">
<div class="input">
<div class="prompt input_prompt">In&nbsp;[1]:</div>
<div class="inner_cell">
    <div class="input_area">
<div class=" highlight hl-ipython3"><pre><span></span><span class="c1"># comes with Python</span>
<span class="kn">import</span> <span class="nn">json</span>

<span class="c1"># third-party</span>
<span class="kn">import</span> <span class="nn">requests</span>
<span class="kn">from</span> <span class="nn">requests.auth</span> <span class="k">import</span> <span class="n">HTTPBasicAuth</span>
<span class="kn">import</span> <span class="nn">geocoder</span>
<span class="kn">import</span> <span class="nn">pandas</span> <span class="k">as</span> <span class="nn">pd</span>

</pre></div>

    </div>

</div>
</div>

</div>
<div class="cell border-box-sizing text_cell rendered"><div class="prompt input_prompt">
</div><div class="inner_cell">
<div class="text_cell_render border-box-sizing rendered_html">
<h2 id="Get-credentials">Get credentials<a class="anchor-link" href="#Get-credentials">&#182;</a></h2><p>Next, we need to <a href="https://new-console.ng.bluemix.net/catalog/services/insights-for-weather/">provision an Insights for Weather service instance</a> on Bluemix and get the access credentials. We can follow the instructions about <a href="https://new-console.ng.bluemix.net/docs/services/Weather/index.html#addservice">Adding Insights for Weather to your application</a> to do so.</p>

</div>
</div>
</div>
<div class="cell border-box-sizing text_cell rendered"><div class="prompt input_prompt">
</div><div class="inner_cell">
<div class="text_cell_render border-box-sizing rendered_html">
<p>To keep our credentials out of this notebook, we can copy them from the Bluemix UI put them in a <code>weather_creds.json</code> file alongside this notebook. The credentials JSON should look something like the following.</p>

<pre><code>{
  "credentials": {
    "username": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
    "password": "yyyyyyyyyy",
    "host": "twcservice.mybluemix.net",
    "port": 443,
    "url": "https://xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx:yyyyyyyyyy@twcservice.mybluemix.net"
  }
}</code></pre>

</div>
</div>
</div>
<div class="cell border-box-sizing text_cell rendered"><div class="prompt input_prompt">
</div><div class="inner_cell">
<div class="text_cell_render border-box-sizing rendered_html">
<p>Now we can load that file into memory without showing its contents here.</p>

</div>
</div>
</div>
<div class="cell border-box-sizing code_cell rendered">
<div class="input">
<div class="prompt input_prompt">In&nbsp;[2]:</div>
<div class="inner_cell">
    <div class="input_area">
<div class=" highlight hl-ipython3"><pre><span></span><span class="k">with</span> <span class="nb">open</span><span class="p">(</span><span class="s1">&#39;weather_creds.json&#39;</span><span class="p">)</span> <span class="k">as</span> <span class="n">f</span><span class="p">:</span>
    <span class="n">creds</span> <span class="o">=</span> <span class="n">json</span><span class="o">.</span><span class="n">load</span><span class="p">(</span><span class="n">f</span><span class="p">)</span>
</pre></div>

    </div>

</div>
</div>

</div>
<div class="cell border-box-sizing text_cell rendered"><div class="prompt input_prompt">
</div><div class="inner_cell">
<div class="text_cell_render border-box-sizing rendered_html">
<h2 id="Try-a-request">Try a request<a class="anchor-link" href="#Try-a-request">&#182;</a></h2><p>Now we're ready to try a request against the <a href="https://new-console.ng.bluemix.net/docs/services/Weather/index.html#api_docs">REST API</a>. We'll do this using the <a href="http://docs.python-requests.org/en/master/">requests</a> Python package.</p>
<p class="alert alert-warning">Note: At the time of this writing, the paths documented in the REST API section of the docs are incorrect. Remove the `/geocode` section of the path and it should work. The other samples and API references in the docs are correct.</p>
</div>
</div>
</div>
<div class="cell border-box-sizing text_cell rendered"><div class="prompt input_prompt">
</div><div class="inner_cell">
<div class="text_cell_render border-box-sizing rendered_html">
<p>First we need to build a basic auth object with our service username and password.</p>

</div>
</div>
</div>
<div class="cell border-box-sizing code_cell rendered">
<div class="input">
<div class="prompt input_prompt">In&nbsp;[3]:</div>
<div class="inner_cell">
    <div class="input_area">
<div class=" highlight hl-ipython3"><pre><span></span><span class="n">auth</span> <span class="o">=</span> <span class="n">HTTPBasicAuth</span><span class="p">(</span><span class="n">creds</span><span class="p">[</span><span class="s1">&#39;credentials&#39;</span><span class="p">][</span><span class="s1">&#39;username&#39;</span><span class="p">],</span> 
                     <span class="n">creds</span><span class="p">[</span><span class="s1">&#39;credentials&#39;</span><span class="p">][</span><span class="s1">&#39;password&#39;</span><span class="p">])</span>
</pre></div>

    </div>

</div>
</div>

</div>
<div class="cell border-box-sizing text_cell rendered"><div class="prompt input_prompt">
</div><div class="inner_cell">
<div class="text_cell_render border-box-sizing rendered_html">
<p>Then we can build the base URL of the service.</p>

</div>
</div>
</div>
<div class="cell border-box-sizing code_cell rendered">
<div class="input">
<div class="prompt input_prompt">In&nbsp;[4]:</div>
<div class="inner_cell">
    <div class="input_area">
<div class=" highlight hl-ipython3"><pre><span></span><span class="n">url</span> <span class="o">=</span> <span class="s1">&#39;https://</span><span class="si">{}</span><span class="s1">/api/weather/v2&#39;</span><span class="o">.</span><span class="n">format</span><span class="p">(</span><span class="n">creds</span><span class="p">[</span><span class="s1">&#39;credentials&#39;</span><span class="p">][</span><span class="s1">&#39;host&#39;</span><span class="p">])</span>
<span class="n">url</span>
</pre></div>

    </div>

</div>
</div>

<div class="output_wrapper">
<div class="output">

<div class="output_area">

    <div class="prompt output_prompt">Out[4]:</div>

<div class="output_text output_subarea output_execute_result">
<pre>&#39;https://twcservice.mybluemix.net/api/weather/v2&#39;</pre>
</div>

</div>

</div>
</div>

</div>
<div class="cell border-box-sizing text_cell rendered"><div class="prompt input_prompt">
</div><div class="inner_cell">
<div class="text_cell_render border-box-sizing rendered_html">
<p>The API documentation says we need to pass latitude and longitude coordinates with our queries. Instead of hardcoding one here, we'll use the Google geocoder to get the lat/lng for my hometown.</p>

</div>
</div>
</div>
<div class="cell border-box-sizing code_cell rendered">
<div class="input">
<div class="prompt input_prompt">In&nbsp;[5]:</div>
<div class="inner_cell">
    <div class="input_area">
<div class=" highlight hl-ipython3"><pre><span></span><span class="n">g</span> <span class="o">=</span> <span class="n">geocoder</span><span class="o">.</span><span class="n">google</span><span class="p">(</span><span class="s1">&#39;Durham, NC&#39;</span><span class="p">)</span>
<span class="n">g</span>
</pre></div>

    </div>

</div>
</div>

<div class="output_wrapper">
<div class="output">

<div class="output_area">

    <div class="prompt output_prompt">Out[5]:</div>

<div class="output_text output_subarea output_execute_result">
<pre>&lt;[OK] Google - Geocode [Durham, NC, USA]&gt;</pre>
</div>

</div>

</div>
</div>

</div>
<div class="cell border-box-sizing text_cell rendered"><div class="prompt input_prompt">
</div><div class="inner_cell">
<div class="text_cell_render border-box-sizing rendered_html">
<p>With these in hand, we'll build up a dictionary which requests will convert into URL query args for us. Besides the geocode, we'll include other parameters like the desired unit of measurement and language of the response. (These are all <a href="https://new-console.ng.bluemix.net/docs/services/Weather/index.html#api_docs">noted in the API docs</a>.)</p>

</div>
</div>
</div>
<div class="cell border-box-sizing code_cell rendered">
<div class="input">
<div class="prompt input_prompt">In&nbsp;[6]:</div>
<div class="inner_cell">
    <div class="input_area">
<div class=" highlight hl-ipython3"><pre><span></span><span class="n">params</span> <span class="o">=</span> <span class="p">{</span>
    <span class="s1">&#39;geocode&#39;</span> <span class="p">:</span> <span class="s1">&#39;</span><span class="si">{:.2f}</span><span class="s1">,</span><span class="si">{:.2f}</span><span class="s1">&#39;</span><span class="o">.</span><span class="n">format</span><span class="p">(</span><span class="n">g</span><span class="o">.</span><span class="n">lat</span><span class="p">,</span> <span class="n">g</span><span class="o">.</span><span class="n">lng</span><span class="p">),</span>
    <span class="s1">&#39;units&#39;</span><span class="p">:</span> <span class="s1">&#39;e&#39;</span><span class="p">,</span>
    <span class="s1">&#39;language&#39;</span><span class="p">:</span> <span class="s1">&#39;en-US&#39;</span>
<span class="p">}</span>
</pre></div>

    </div>

</div>
</div>

</div>
<div class="cell border-box-sizing text_cell rendered"><div class="prompt input_prompt">
</div><div class="inner_cell">
<div class="text_cell_render border-box-sizing rendered_html">
<p>Let's make the request to one of the documented resources to get the 10 day forecast for Durham, NC. We pass the query parameters and our basic auth information.</p>

</div>
</div>
</div>
<div class="cell border-box-sizing code_cell rendered">
<div class="input">
<div class="prompt input_prompt">In&nbsp;[7]:</div>
<div class="inner_cell">
    <div class="input_area">
<div class=" highlight hl-ipython3"><pre><span></span><span class="n">resp</span> <span class="o">=</span> <span class="n">requests</span><span class="o">.</span><span class="n">get</span><span class="p">(</span><span class="n">url</span><span class="o">+</span><span class="s1">&#39;/forecast/daily/10day&#39;</span><span class="p">,</span> <span class="n">params</span><span class="o">=</span><span class="n">params</span><span class="p">,</span> <span class="n">auth</span><span class="o">=</span><span class="n">auth</span><span class="p">)</span>
</pre></div>

    </div>

</div>
</div>

</div>
<div class="cell border-box-sizing text_cell rendered"><div class="prompt input_prompt">
</div><div class="inner_cell">
<div class="text_cell_render border-box-sizing rendered_html">
<p>We can sanity check that the response status is OK easily. If anything went wrong with our request, the next line of code will raise an exception</p>

</div>
</div>
</div>
<div class="cell border-box-sizing code_cell rendered">
<div class="input">
<div class="prompt input_prompt">In&nbsp;[8]:</div>
<div class="inner_cell">
    <div class="input_area">
<div class=" highlight hl-ipython3"><pre><span></span><span class="n">resp</span><span class="o">.</span><span class="n">raise_for_status</span><span class="p">()</span>
</pre></div>

    </div>

</div>
</div>

</div>
<div class="cell border-box-sizing text_cell rendered"><div class="prompt input_prompt">
</div><div class="inner_cell">
<div class="text_cell_render border-box-sizing rendered_html">
<h2 id="Look-at-the-response">Look at the response<a class="anchor-link" href="#Look-at-the-response">&#182;</a></h2>
</div>
</div>
</div>
<div class="cell border-box-sizing text_cell rendered"><div class="prompt input_prompt">
</div><div class="inner_cell">
<div class="text_cell_render border-box-sizing rendered_html">
<p>If we made it this far, our call was successful. Let's look at the results. We parse the JSON body of the response into a Python dictionary.</p>

</div>
</div>
</div>
<div class="cell border-box-sizing code_cell rendered">
<div class="input">
<div class="prompt input_prompt">In&nbsp;[9]:</div>
<div class="inner_cell">
    <div class="input_area">
<div class=" highlight hl-ipython3"><pre><span></span><span class="n">body</span> <span class="o">=</span> <span class="n">resp</span><span class="o">.</span><span class="n">json</span><span class="p">()</span>
</pre></div>

    </div>

</div>
</div>

</div>
<div class="cell border-box-sizing text_cell rendered"><div class="prompt input_prompt">
</div><div class="inner_cell">
<div class="text_cell_render border-box-sizing rendered_html">
<p>Let's see what keys are in the body without printing the whole thing.</p>

</div>
</div>
</div>
<div class="cell border-box-sizing code_cell rendered">
<div class="input">
<div class="prompt input_prompt">In&nbsp;[10]:</div>
<div class="inner_cell">
    <div class="input_area">
<div class=" highlight hl-ipython3"><pre><span></span><span class="n">body</span><span class="o">.</span><span class="n">keys</span><span class="p">()</span>
</pre></div>

    </div>

</div>
</div>

<div class="output_wrapper">
<div class="output">

<div class="output_area">

    <div class="prompt output_prompt">Out[10]:</div>

<div class="output_text output_subarea output_execute_result">
<pre>dict_keys([&#39;forecasts&#39;, &#39;metadata&#39;])</pre>
</div>

</div>

</div>
</div>

</div>
<div class="cell border-box-sizing text_cell rendered"><div class="prompt input_prompt">
</div><div class="inner_cell">
<div class="text_cell_render border-box-sizing rendered_html">
<p>And let's take a closer look at the forecasts. Instead of printing the raw, potentially nested Python dictionary, we'll ask pandas to take a crack at it and give us a nicer table view of the data in our notebook.</p>

</div>
</div>
</div>
<div class="cell border-box-sizing code_cell rendered">
<div class="input">
<div class="prompt input_prompt">In&nbsp;[11]:</div>
<div class="inner_cell">
    <div class="input_area">
<div class=" highlight hl-ipython3"><pre><span></span><span class="n">df</span> <span class="o">=</span> <span class="n">pd</span><span class="o">.</span><span class="n">io</span><span class="o">.</span><span class="n">json</span><span class="o">.</span><span class="n">json_normalize</span><span class="p">(</span><span class="n">body</span><span class="p">[</span><span class="s1">&#39;forecasts&#39;</span><span class="p">])</span>
</pre></div>

    </div>

</div>
</div>

</div>
<div class="cell border-box-sizing text_cell rendered"><div class="prompt input_prompt">
</div><div class="inner_cell">
<div class="text_cell_render border-box-sizing rendered_html">
<p>How many columns do we have?</p>

</div>
</div>
</div>
<div class="cell border-box-sizing code_cell rendered">
<div class="input">
<div class="prompt input_prompt">In&nbsp;[12]:</div>
<div class="inner_cell">
    <div class="input_area">
<div class=" highlight hl-ipython3"><pre><span></span><span class="nb">len</span><span class="p">(</span><span class="n">df</span><span class="o">.</span><span class="n">columns</span><span class="p">)</span>
</pre></div>

    </div>

</div>
</div>

<div class="output_wrapper">
<div class="output">

<div class="output_area">

    <div class="prompt output_prompt">Out[12]:</div>

<div class="output_text output_subarea output_execute_result">
<pre>123</pre>
</div>

</div>

</div>
</div>

</div>
<div class="cell border-box-sizing text_cell rendered"><div class="prompt input_prompt">
</div><div class="inner_cell">
<div class="text_cell_render border-box-sizing rendered_html">
<p>Quite a few. Let's make sure pandas shows them all.</p>

</div>
</div>
</div>
<div class="cell border-box-sizing code_cell rendered">
<div class="input">
<div class="prompt input_prompt">In&nbsp;[13]:</div>
<div class="inner_cell">
    <div class="input_area">
<div class=" highlight hl-ipython3"><pre><span></span><span class="n">pd</span><span class="o">.</span><span class="n">options</span><span class="o">.</span><span class="n">display</span><span class="o">.</span><span class="n">max_columns</span> <span class="o">=</span> <span class="mi">125</span>
</pre></div>

    </div>

</div>
</div>

</div>
<div class="cell border-box-sizing text_cell rendered"><div class="prompt input_prompt">
</div><div class="inner_cell">
<div class="text_cell_render border-box-sizing rendered_html">
<p>And now we can emit the entire thing as a nice HTML table for inspection.</p>

</div>
</div>
</div>
<div class="cell border-box-sizing code_cell rendered">
<div class="input">
<div class="prompt input_prompt">In&nbsp;[14]:</div>
<div class="inner_cell">
    <div class="input_area">
<div class=" highlight hl-ipython3"><pre><span></span><span class="n">df</span>
</pre></div>

    </div>

</div>
</div>

<div class="output_wrapper">
<div class="output">

<div class="output_area">

    <div class="prompt output_prompt">Out[14]:</div>

<div class="output_html rendered_html output_subarea output_execute_result">
<div>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>blurb</th>
      <th>blurb_author</th>
      <th>class</th>
      <th>day.accumulation_phrase</th>
      <th>day.alt_daypart_name</th>
      <th>day.clds</th>
      <th>day.day_ind</th>
      <th>day.daypart_name</th>
      <th>day.fcst_valid</th>
      <th>day.fcst_valid_local</th>
      <th>day.golf_category</th>
      <th>day.golf_index</th>
      <th>day.hi</th>
      <th>day.icon_code</th>
      <th>day.icon_extd</th>
      <th>day.long_daypart_name</th>
      <th>day.narrative</th>
      <th>day.num</th>
      <th>day.phrase_12char</th>
      <th>day.phrase_22char</th>
      <th>day.phrase_32char</th>
      <th>day.pop</th>
      <th>day.pop_phrase</th>
      <th>day.precip_type</th>
      <th>day.qpf</th>
      <th>day.qualifier</th>
      <th>day.qualifier_code</th>
      <th>day.rh</th>
      <th>day.shortcast</th>
      <th>day.snow_code</th>
      <th>day.snow_phrase</th>
      <th>day.snow_qpf</th>
      <th>day.snow_range</th>
      <th>day.subphrase_pt1</th>
      <th>day.subphrase_pt2</th>
      <th>day.subphrase_pt3</th>
      <th>day.temp</th>
      <th>day.temp_phrase</th>
      <th>day.thunder_enum</th>
      <th>day.thunder_enum_phrase</th>
      <th>day.uv_desc</th>
      <th>day.uv_index</th>
      <th>day.uv_index_raw</th>
      <th>day.uv_warning</th>
      <th>day.vocal_key</th>
      <th>day.wc</th>
      <th>day.wdir</th>
      <th>day.wdir_cardinal</th>
      <th>day.wind_phrase</th>
      <th>day.wspd</th>
      <th>day.wxman</th>
      <th>dow</th>
      <th>expire_time_gmt</th>
      <th>fcst_valid</th>
      <th>fcst_valid_local</th>
      <th>lunar_phase</th>
      <th>lunar_phase_code</th>
      <th>lunar_phase_day</th>
      <th>max_temp</th>
      <th>min_temp</th>
      <th>moonrise</th>
      <th>moonset</th>
      <th>narrative</th>
      <th>night.accumulation_phrase</th>
      <th>night.alt_daypart_name</th>
      <th>night.clds</th>
      <th>night.day_ind</th>
      <th>night.daypart_name</th>
      <th>night.fcst_valid</th>
      <th>night.fcst_valid_local</th>
      <th>night.golf_category</th>
      <th>night.golf_index</th>
      <th>night.hi</th>
      <th>night.icon_code</th>
      <th>night.icon_extd</th>
      <th>night.long_daypart_name</th>
      <th>night.narrative</th>
      <th>night.num</th>
      <th>night.phrase_12char</th>
      <th>night.phrase_22char</th>
      <th>night.phrase_32char</th>
      <th>night.pop</th>
      <th>night.pop_phrase</th>
      <th>night.precip_type</th>
      <th>night.qpf</th>
      <th>night.qualifier</th>
      <th>night.qualifier_code</th>
      <th>night.rh</th>
      <th>night.shortcast</th>
      <th>night.snow_code</th>
      <th>night.snow_phrase</th>
      <th>night.snow_qpf</th>
      <th>night.snow_range</th>
      <th>night.subphrase_pt1</th>
      <th>night.subphrase_pt2</th>
      <th>night.subphrase_pt3</th>
      <th>night.temp</th>
      <th>night.temp_phrase</th>
      <th>night.thunder_enum</th>
      <th>night.thunder_enum_phrase</th>
      <th>night.uv_desc</th>
      <th>night.uv_index</th>
      <th>night.uv_index_raw</th>
      <th>night.uv_warning</th>
      <th>night.vocal_key</th>
      <th>night.wc</th>
      <th>night.wdir</th>
      <th>night.wdir_cardinal</th>
      <th>night.wind_phrase</th>
      <th>night.wspd</th>
      <th>night.wxman</th>
      <th>num</th>
      <th>qpf</th>
      <th>qualifier</th>
      <th>qualifier_code</th>
      <th>snow_code</th>
      <th>snow_phrase</th>
      <th>snow_qpf</th>
      <th>snow_range</th>
      <th>stormcon</th>
      <th>sunrise</th>
      <th>sunset</th>
      <th>torcon</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>None</td>
      <td>None</td>
      <td>fod_long_range_daily</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>Thursday</td>
      <td>1460664024</td>
      <td>1460631600</td>
      <td>2016-04-14T07:00:00-0400</td>
      <td>Waxing Gibbous</td>
      <td>WXG</td>
      <td>8</td>
      <td>NaN</td>
      <td>40</td>
      <td>2016-04-14T13:07:47-0400</td>
      <td>2016-04-14T02:22:10-0400</td>
      <td>Partly cloudy. Lows overnight in the low 40s.</td>
      <td></td>
      <td>Tonight</td>
      <td>32</td>
      <td>N</td>
      <td>Tonight</td>
      <td>1460674800</td>
      <td>2016-04-14T19:00:00-0400</td>
      <td></td>
      <td>None</td>
      <td>65</td>
      <td>29</td>
      <td>2900</td>
      <td>Thursday night</td>
      <td>A few clouds. Low around 40F. Winds ENE at 5 t...</td>
      <td>1</td>
      <td>P Cloudy</td>
      <td>Partly Cloudy</td>
      <td>Partly Cloudy</td>
      <td>0</td>
      <td></td>
      <td>rain</td>
      <td>0</td>
      <td>None</td>
      <td>None</td>
      <td>45</td>
      <td>Partly cloudy</td>
      <td></td>
      <td></td>
      <td>0</td>
      <td></td>
      <td>Partly</td>
      <td>Cloudy</td>
      <td></td>
      <td>40</td>
      <td>Low around 40F.</td>
      <td>0</td>
      <td>No thunder</td>
      <td>Low</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>D2:DA02:X3000300023:S300021:TL40:W03R02</td>
      <td>40</td>
      <td>61</td>
      <td>ENE</td>
      <td>Winds ENE at 5 to 10 mph.</td>
      <td>7</td>
      <td>wx1650</td>
      <td>1</td>
      <td>0</td>
      <td>None</td>
      <td>None</td>
      <td></td>
      <td></td>
      <td>0</td>
      <td></td>
      <td>None</td>
      <td>2016-04-14T06:43:06-0400</td>
      <td>2016-04-14T19:49:09-0400</td>
      <td>None</td>
    </tr>
    <tr>
      <th>1</th>
      <td>None</td>
      <td>None</td>
      <td>fod_long_range_daily</td>
      <td></td>
      <td>Friday</td>
      <td>56</td>
      <td>D</td>
      <td>Tomorrow</td>
      <td>1460718000</td>
      <td>2016-04-15T07:00:00-0400</td>
      <td>Very Good</td>
      <td>9</td>
      <td>65</td>
      <td>30</td>
      <td>3000</td>
      <td>Friday</td>
      <td>Intervals of clouds and sunshine. High 67F. Wi...</td>
      <td>2</td>
      <td>P Cloudy</td>
      <td>Partly Cloudy</td>
      <td>Partly Cloudy</td>
      <td>0</td>
      <td></td>
      <td>rain</td>
      <td>0</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>40</td>
      <td>Times of sun and clouds</td>
      <td></td>
      <td></td>
      <td>0</td>
      <td></td>
      <td>Partly</td>
      <td>Cloudy</td>
      <td></td>
      <td>67</td>
      <td>High 67F.</td>
      <td>0</td>
      <td>No thunder</td>
      <td>Very High</td>
      <td>8</td>
      <td>7.95</td>
      <td>0</td>
      <td>D3:DA14:X3000300031:S300033:TH67:W02R03</td>
      <td>40</td>
      <td>55</td>
      <td>NE</td>
      <td>Winds NE at 10 to 15 mph.</td>
      <td>11</td>
      <td>wx1100</td>
      <td>Friday</td>
      <td>1460664024</td>
      <td>1460718000</td>
      <td>2016-04-15T07:00:00-0400</td>
      <td>Waxing Gibbous</td>
      <td>WXG</td>
      <td>9</td>
      <td>67</td>
      <td>39</td>
      <td>2016-04-15T14:05:00-0400</td>
      <td>2016-04-15T03:05:43-0400</td>
      <td>Mix of sun and clouds. Highs in the upper 60s ...</td>
      <td></td>
      <td>Friday night</td>
      <td>56</td>
      <td>N</td>
      <td>Tomorrow night</td>
      <td>1460761200</td>
      <td>2016-04-15T19:00:00-0400</td>
      <td></td>
      <td>None</td>
      <td>61</td>
      <td>29</td>
      <td>2900</td>
      <td>Friday night</td>
      <td>A few clouds from time to time. Low 39F. Winds...</td>
      <td>3</td>
      <td>P Cloudy</td>
      <td>Partly Cloudy</td>
      <td>Partly Cloudy</td>
      <td>0</td>
      <td></td>
      <td>precip</td>
      <td>0</td>
      <td>None</td>
      <td>None</td>
      <td>48</td>
      <td>Partly cloudy</td>
      <td></td>
      <td></td>
      <td>0</td>
      <td></td>
      <td>Partly</td>
      <td>Cloudy</td>
      <td></td>
      <td>39</td>
      <td>Low 39F.</td>
      <td>0</td>
      <td>No thunder</td>
      <td>Low</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>D4:DA15:X3000300042:S300042:TL39:W02R02</td>
      <td>41</td>
      <td>53</td>
      <td>NE</td>
      <td>Winds NE at 5 to 10 mph.</td>
      <td>7</td>
      <td>wx1650</td>
      <td>2</td>
      <td>0</td>
      <td>None</td>
      <td>None</td>
      <td></td>
      <td></td>
      <td>0</td>
      <td></td>
      <td>None</td>
      <td>2016-04-15T06:41:46-0400</td>
      <td>2016-04-15T19:49:59-0400</td>
      <td>None</td>
    </tr>
    <tr>
      <th>2</th>
      <td>None</td>
      <td>None</td>
      <td>fod_long_range_daily</td>
      <td></td>
      <td>Saturday</td>
      <td>52</td>
      <td>D</td>
      <td>Saturday</td>
      <td>1460804400</td>
      <td>2016-04-16T07:00:00-0400</td>
      <td>Excellent</td>
      <td>10</td>
      <td>69</td>
      <td>30</td>
      <td>3000</td>
      <td>Saturday</td>
      <td>Intervals of clouds and sunshine. High 71F. Wi...</td>
      <td>4</td>
      <td>P Cloudy</td>
      <td>Partly Cloudy</td>
      <td>Partly Cloudy</td>
      <td>0</td>
      <td></td>
      <td>rain</td>
      <td>0</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>37</td>
      <td>Mix of sun and clouds</td>
      <td></td>
      <td></td>
      <td>0</td>
      <td></td>
      <td>Partly</td>
      <td>Cloudy</td>
      <td></td>
      <td>71</td>
      <td>High 71F.</td>
      <td>0</td>
      <td>No thunder</td>
      <td>High</td>
      <td>7</td>
      <td>7.37</td>
      <td>0</td>
      <td>D5:DA16:X3000300031:S300032:TH71:W02R03</td>
      <td>41</td>
      <td>37</td>
      <td>NE</td>
      <td>Winds NE at 10 to 15 mph.</td>
      <td>10</td>
      <td>wx1100</td>
      <td>Saturday</td>
      <td>1460664024</td>
      <td>1460804400</td>
      <td>2016-04-16T07:00:00-0400</td>
      <td>Waxing Gibbous</td>
      <td>WXG</td>
      <td>10</td>
      <td>71</td>
      <td>42</td>
      <td>2016-04-16T15:01:38-0400</td>
      <td>2016-04-16T03:44:32-0400</td>
      <td>Times of sun and clouds. Highs in the low 70s ...</td>
      <td></td>
      <td>Saturday night</td>
      <td>9</td>
      <td>N</td>
      <td>Saturday night</td>
      <td>1460847600</td>
      <td>2016-04-16T19:00:00-0400</td>
      <td></td>
      <td>None</td>
      <td>64</td>
      <td>29</td>
      <td>2900</td>
      <td>Saturday night</td>
      <td>Partly cloudy skies. Low 42F. Winds light and ...</td>
      <td>5</td>
      <td>P Cloudy</td>
      <td>Partly Cloudy</td>
      <td>Partly Cloudy</td>
      <td>0</td>
      <td></td>
      <td>rain</td>
      <td>0</td>
      <td>None</td>
      <td>None</td>
      <td>57</td>
      <td>Partly cloudy</td>
      <td></td>
      <td></td>
      <td>0</td>
      <td></td>
      <td>Partly</td>
      <td>Cloudy</td>
      <td></td>
      <td>42</td>
      <td>Low 42F.</td>
      <td>0</td>
      <td>No thunder</td>
      <td>Low</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>D6:DA17:X3000320041:S300043:TL42:W9902</td>
      <td>44</td>
      <td>46</td>
      <td>NE</td>
      <td>Winds light and variable.</td>
      <td>4</td>
      <td>wx1650</td>
      <td>3</td>
      <td>0</td>
      <td>None</td>
      <td>None</td>
      <td></td>
      <td></td>
      <td>0</td>
      <td></td>
      <td>None</td>
      <td>2016-04-16T06:40:26-0400</td>
      <td>2016-04-16T19:50:49-0400</td>
      <td>None</td>
    </tr>
    <tr>
      <th>3</th>
      <td>None</td>
      <td>None</td>
      <td>fod_long_range_daily</td>
      <td></td>
      <td>Sunday</td>
      <td>0</td>
      <td>D</td>
      <td>Sunday</td>
      <td>1460890800</td>
      <td>2016-04-17T07:00:00-0400</td>
      <td>Excellent</td>
      <td>10</td>
      <td>71</td>
      <td>32</td>
      <td>3200</td>
      <td>Sunday</td>
      <td>Mainly sunny. High 73F. Winds NNE at 5 to 10 mph.</td>
      <td>6</td>
      <td>Sunny</td>
      <td>Sunny</td>
      <td>Sunny</td>
      <td>0</td>
      <td></td>
      <td>rain</td>
      <td>0</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>37</td>
      <td>Sunny</td>
      <td></td>
      <td></td>
      <td>0</td>
      <td></td>
      <td>Sunny</td>
      <td></td>
      <td></td>
      <td>73</td>
      <td>High 73F.</td>
      <td>0</td>
      <td>No thunder</td>
      <td>Very High</td>
      <td>8</td>
      <td>8.07</td>
      <td>0</td>
      <td>D7:DA04:X3200320034:S320032:TH73:W01R02</td>
      <td>44</td>
      <td>31</td>
      <td>NNE</td>
      <td>Winds NNE at 5 to 10 mph.</td>
      <td>9</td>
      <td>wx1000</td>
      <td>Sunday</td>
      <td>1460664024</td>
      <td>1460890800</td>
      <td>2016-04-17T07:00:00-0400</td>
      <td>Waxing Gibbous</td>
      <td>WXG</td>
      <td>10</td>
      <td>73</td>
      <td>44</td>
      <td>2016-04-17T15:57:12-0400</td>
      <td>2016-04-17T04:19:17-0400</td>
      <td>Abundant sunshine. Highs in the low 70s and lo...</td>
      <td></td>
      <td>Sunday night</td>
      <td>0</td>
      <td>N</td>
      <td>Sunday night</td>
      <td>1460934000</td>
      <td>2016-04-17T19:00:00-0400</td>
      <td></td>
      <td>None</td>
      <td>66</td>
      <td>31</td>
      <td>3100</td>
      <td>Sunday night</td>
      <td>Clear skies. Low 44F. Winds light and variable.</td>
      <td>7</td>
      <td>Clear</td>
      <td>Clear</td>
      <td>Clear</td>
      <td>0</td>
      <td></td>
      <td>rain</td>
      <td>0</td>
      <td>None</td>
      <td>None</td>
      <td>54</td>
      <td>Clear</td>
      <td></td>
      <td></td>
      <td>0</td>
      <td></td>
      <td>Clear</td>
      <td></td>
      <td></td>
      <td>44</td>
      <td>Low 44F.</td>
      <td>0</td>
      <td>No thunder</td>
      <td>Low</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>D8:DA05:X3200320041:S320044:TL44:W9902</td>
      <td>46</td>
      <td>36</td>
      <td>NE</td>
      <td>Winds light and variable.</td>
      <td>5</td>
      <td>wx1550</td>
      <td>4</td>
      <td>0</td>
      <td>None</td>
      <td>None</td>
      <td></td>
      <td></td>
      <td>0</td>
      <td></td>
      <td>None</td>
      <td>2016-04-17T06:39:07-0400</td>
      <td>2016-04-17T19:51:39-0400</td>
      <td>None</td>
    </tr>
    <tr>
      <th>4</th>
      <td>None</td>
      <td>None</td>
      <td>fod_long_range_daily</td>
      <td></td>
      <td>Monday</td>
      <td>0</td>
      <td>D</td>
      <td>Monday</td>
      <td>1460977200</td>
      <td>2016-04-18T07:00:00-0400</td>
      <td>Very Good</td>
      <td>9</td>
      <td>80</td>
      <td>32</td>
      <td>3200</td>
      <td>Monday</td>
      <td>A mainly sunny sky. High 82F. Winds light and ...</td>
      <td>8</td>
      <td>Sunny</td>
      <td>Sunny</td>
      <td>Sunny</td>
      <td>0</td>
      <td></td>
      <td>rain</td>
      <td>0</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>39</td>
      <td>Sunshine</td>
      <td></td>
      <td></td>
      <td>0</td>
      <td></td>
      <td>Sunny</td>
      <td></td>
      <td></td>
      <td>82</td>
      <td>High 82F.</td>
      <td>0</td>
      <td>No thunder</td>
      <td>Very High</td>
      <td>8</td>
      <td>8.13</td>
      <td>0</td>
      <td>D9:DA06:X3200320033:S320034:TH82:W9902</td>
      <td>46</td>
      <td>331</td>
      <td>NNW</td>
      <td>Winds light and variable.</td>
      <td>4</td>
      <td>wx1000</td>
      <td>Monday</td>
      <td>1460664024</td>
      <td>1460977200</td>
      <td>2016-04-18T07:00:00-0400</td>
      <td>Waxing Gibbous</td>
      <td>WXG</td>
      <td>11</td>
      <td>82</td>
      <td>54</td>
      <td>2016-04-18T16:51:43-0400</td>
      <td>2016-04-18T04:52:14-0400</td>
      <td>Sunny. Highs in the low 80s and lows in the mi...</td>
      <td></td>
      <td>Monday night</td>
      <td>9</td>
      <td>N</td>
      <td>Monday night</td>
      <td>1461020400</td>
      <td>2016-04-18T19:00:00-0400</td>
      <td></td>
      <td>None</td>
      <td>73</td>
      <td>31</td>
      <td>3100</td>
      <td>Monday night</td>
      <td>Clear skies. Low 54F. Winds light and variable.</td>
      <td>9</td>
      <td>Clear</td>
      <td>Clear</td>
      <td>Clear</td>
      <td>0</td>
      <td></td>
      <td>rain</td>
      <td>0</td>
      <td>None</td>
      <td>None</td>
      <td>58</td>
      <td>Mainly clear</td>
      <td></td>
      <td></td>
      <td>0</td>
      <td></td>
      <td>Clear</td>
      <td></td>
      <td></td>
      <td>54</td>
      <td>Low 54F.</td>
      <td>0</td>
      <td>No thunder</td>
      <td>Low</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>D10:DA07:X3200320044:S320041:TL54:W9902</td>
      <td>55</td>
      <td>292</td>
      <td>WNW</td>
      <td>Winds light and variable.</td>
      <td>4</td>
      <td>wx1500</td>
      <td>5</td>
      <td>0</td>
      <td>None</td>
      <td>None</td>
      <td></td>
      <td></td>
      <td>0</td>
      <td></td>
      <td>None</td>
      <td>2016-04-18T06:37:49-0400</td>
      <td>2016-04-18T19:52:29-0400</td>
      <td>None</td>
    </tr>
    <tr>
      <th>5</th>
      <td>None</td>
      <td>None</td>
      <td>fod_long_range_daily</td>
      <td></td>
      <td>Tuesday</td>
      <td>44</td>
      <td>D</td>
      <td>Tuesday</td>
      <td>1461063600</td>
      <td>2016-04-19T07:00:00-0400</td>
      <td>Very Good</td>
      <td>9</td>
      <td>78</td>
      <td>30</td>
      <td>3000</td>
      <td>Tuesday</td>
      <td>Sunshine and clouds mixed. High near 80F. Wind...</td>
      <td>10</td>
      <td>P Cloudy</td>
      <td>Partly Cloudy</td>
      <td>Partly Cloudy</td>
      <td>0</td>
      <td></td>
      <td>rain</td>
      <td>0</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>43</td>
      <td>Partly cloudy</td>
      <td></td>
      <td></td>
      <td>0</td>
      <td></td>
      <td>Partly</td>
      <td>Cloudy</td>
      <td></td>
      <td>80</td>
      <td>High near 80F.</td>
      <td>0</td>
      <td>No thunder</td>
      <td>Very High</td>
      <td>8</td>
      <td>8.18</td>
      <td>0</td>
      <td>D11:DA08:X3000300034:S300031:TH80:W15R02</td>
      <td>55</td>
      <td>347</td>
      <td>NNW</td>
      <td>Winds NNW at 5 to 10 mph.</td>
      <td>7</td>
      <td>wx1100</td>
      <td>Tuesday</td>
      <td>1460664024</td>
      <td>1461063600</td>
      <td>2016-04-19T07:00:00-0400</td>
      <td>Waxing Gibbous</td>
      <td>WXG</td>
      <td>12</td>
      <td>80</td>
      <td>52</td>
      <td>2016-04-19T17:46:07-0400</td>
      <td>2016-04-19T05:23:58-0400</td>
      <td>Partly cloudy. Highs in the low 80s and lows i...</td>
      <td></td>
      <td>Tuesday night</td>
      <td>51</td>
      <td>N</td>
      <td>Tuesday night</td>
      <td>1461106800</td>
      <td>2016-04-19T19:00:00-0400</td>
      <td></td>
      <td>None</td>
      <td>72</td>
      <td>29</td>
      <td>2900</td>
      <td>Tuesday night</td>
      <td>Partly cloudy. Low 52F. Winds light and variable.</td>
      <td>11</td>
      <td>P Cloudy</td>
      <td>Partly Cloudy</td>
      <td>Partly Cloudy</td>
      <td>0</td>
      <td></td>
      <td>rain</td>
      <td>0</td>
      <td>None</td>
      <td>None</td>
      <td>59</td>
      <td>Partly cloudy</td>
      <td></td>
      <td></td>
      <td>0</td>
      <td></td>
      <td>Partly</td>
      <td>Cloudy</td>
      <td></td>
      <td>52</td>
      <td>Low 52F.</td>
      <td>0</td>
      <td>No thunder</td>
      <td>Low</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>D12:DA09:X3000300043:S300042:TL52:W9902</td>
      <td>53</td>
      <td>37</td>
      <td>NE</td>
      <td>Winds light and variable.</td>
      <td>3</td>
      <td>wx1600</td>
      <td>6</td>
      <td>0</td>
      <td>None</td>
      <td>None</td>
      <td></td>
      <td></td>
      <td>0</td>
      <td></td>
      <td>None</td>
      <td>2016-04-19T06:36:32-0400</td>
      <td>2016-04-19T19:53:19-0400</td>
      <td>None</td>
    </tr>
    <tr>
      <th>6</th>
      <td>None</td>
      <td>None</td>
      <td>fod_long_range_daily</td>
      <td></td>
      <td>Wednesday</td>
      <td>23</td>
      <td>D</td>
      <td>Wednesday</td>
      <td>1461150000</td>
      <td>2016-04-20T07:00:00-0400</td>
      <td>Excellent</td>
      <td>10</td>
      <td>75</td>
      <td>30</td>
      <td>3000</td>
      <td>Wednesday</td>
      <td>Partly cloudy skies. High 77F. Winds N at 5 to...</td>
      <td>12</td>
      <td>P Cloudy</td>
      <td>Partly Cloudy</td>
      <td>Partly Cloudy</td>
      <td>0</td>
      <td></td>
      <td>rain</td>
      <td>0</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>38</td>
      <td>Partly cloudy</td>
      <td></td>
      <td></td>
      <td>0</td>
      <td></td>
      <td>Partly</td>
      <td>Cloudy</td>
      <td></td>
      <td>77</td>
      <td>High 77F.</td>
      <td>0</td>
      <td>No thunder</td>
      <td>Very High</td>
      <td>8</td>
      <td>8.24</td>
      <td>0</td>
      <td>D13:DA10:X3000320031:S300031:TH77:W16R02</td>
      <td>53</td>
      <td>0</td>
      <td>N</td>
      <td>Winds N at 5 to 10 mph.</td>
      <td>6</td>
      <td>wx1100</td>
      <td>Wednesday</td>
      <td>1460664024</td>
      <td>1461150000</td>
      <td>2016-04-20T07:00:00-0400</td>
      <td>Waxing Gibbous</td>
      <td>WXG</td>
      <td>13</td>
      <td>77</td>
      <td>50</td>
      <td>2016-04-20T18:39:35-0400</td>
      <td>2016-04-20T05:54:50-0400</td>
      <td>Times of sun and clouds. Highs in the upper 70...</td>
      <td></td>
      <td>Wednesday night</td>
      <td>5</td>
      <td>N</td>
      <td>Wednesday night</td>
      <td>1461193200</td>
      <td>2016-04-20T19:00:00-0400</td>
      <td></td>
      <td>None</td>
      <td>69</td>
      <td>31</td>
      <td>3100</td>
      <td>Wednesday night</td>
      <td>Clear skies. Low near 50F. Winds light and var...</td>
      <td>13</td>
      <td>Clear</td>
      <td>Clear</td>
      <td>Clear</td>
      <td>0</td>
      <td></td>
      <td>rain</td>
      <td>0</td>
      <td>None</td>
      <td>None</td>
      <td>54</td>
      <td>Clear</td>
      <td></td>
      <td></td>
      <td>0</td>
      <td></td>
      <td>Clear</td>
      <td></td>
      <td></td>
      <td>50</td>
      <td>Low near 50F.</td>
      <td>0</td>
      <td>No thunder</td>
      <td>Low</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>D14:DA11:X3200320041:S320044:TL50:W9902</td>
      <td>51</td>
      <td>159</td>
      <td>SSE</td>
      <td>Winds light and variable.</td>
      <td>3</td>
      <td>wx1500</td>
      <td>7</td>
      <td>0</td>
      <td>None</td>
      <td>None</td>
      <td></td>
      <td></td>
      <td>0</td>
      <td></td>
      <td>None</td>
      <td>2016-04-20T06:35:16-0400</td>
      <td>2016-04-20T19:54:10-0400</td>
      <td>None</td>
    </tr>
    <tr>
      <th>7</th>
      <td>None</td>
      <td>None</td>
      <td>fod_long_range_daily</td>
      <td></td>
      <td>Thursday</td>
      <td>8</td>
      <td>D</td>
      <td>Thursday</td>
      <td>1461236400</td>
      <td>2016-04-21T07:00:00-0400</td>
      <td>Very Good</td>
      <td>9</td>
      <td>78</td>
      <td>32</td>
      <td>3200</td>
      <td>Thursday</td>
      <td>Sunny. High near 80F. Winds WSW at 5 to 10 mph.</td>
      <td>14</td>
      <td>Sunny</td>
      <td>Sunny</td>
      <td>Sunny</td>
      <td>10</td>
      <td></td>
      <td>rain</td>
      <td>0</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>44</td>
      <td>Abundant sunshine</td>
      <td></td>
      <td></td>
      <td>0</td>
      <td></td>
      <td>Sunny</td>
      <td></td>
      <td></td>
      <td>80</td>
      <td>High near 80F.</td>
      <td>0</td>
      <td>No thunder</td>
      <td>Very High</td>
      <td>8</td>
      <td>8.30</td>
      <td>0</td>
      <td>D15:DA12:X3200320032:S320033:TH80:W11R02</td>
      <td>52</td>
      <td>258</td>
      <td>WSW</td>
      <td>Winds WSW at 5 to 10 mph.</td>
      <td>8</td>
      <td>wx1000</td>
      <td>Thursday</td>
      <td>1460664024</td>
      <td>1461236400</td>
      <td>2016-04-21T07:00:00-0400</td>
      <td>Full Moon</td>
      <td>F</td>
      <td>14</td>
      <td>80</td>
      <td>56</td>
      <td>2016-04-21T19:33:54-0400</td>
      <td>2016-04-21T06:25:55-0400</td>
      <td>Sunshine. Highs in the low 80s and lows in the...</td>
      <td></td>
      <td>Thursday night</td>
      <td>32</td>
      <td>N</td>
      <td>Thursday night</td>
      <td>1461279600</td>
      <td>2016-04-21T19:00:00-0400</td>
      <td></td>
      <td>None</td>
      <td>72</td>
      <td>33</td>
      <td>3300</td>
      <td>Thursday night</td>
      <td>Clear skies with a few passing clouds. Low 56F...</td>
      <td>15</td>
      <td>M Clear</td>
      <td>Mostly Clear</td>
      <td>Mostly Clear</td>
      <td>20</td>
      <td></td>
      <td>rain</td>
      <td>0</td>
      <td>None</td>
      <td>None</td>
      <td>62</td>
      <td>A few clouds</td>
      <td></td>
      <td></td>
      <td>0</td>
      <td></td>
      <td>Mostly</td>
      <td>Clear</td>
      <td></td>
      <td>56</td>
      <td>Low 56F.</td>
      <td>0</td>
      <td>No thunder</td>
      <td>Low</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>D16:DA13:X3400300043:S340041:TL56:W10R02</td>
      <td>57</td>
      <td>217</td>
      <td>SW</td>
      <td>Winds SW at 5 to 10 mph.</td>
      <td>6</td>
      <td>wx1500</td>
      <td>8</td>
      <td>0</td>
      <td>None</td>
      <td>None</td>
      <td></td>
      <td></td>
      <td>0</td>
      <td></td>
      <td>None</td>
      <td>2016-04-21T06:34:00-0400</td>
      <td>2016-04-21T19:55:00-0400</td>
      <td>None</td>
    </tr>
    <tr>
      <th>8</th>
      <td>None</td>
      <td>None</td>
      <td>fod_long_range_daily</td>
      <td></td>
      <td>Friday</td>
      <td>46</td>
      <td>D</td>
      <td>Friday</td>
      <td>1461322800</td>
      <td>2016-04-22T07:00:00-0400</td>
      <td>Very Good</td>
      <td>9</td>
      <td>79</td>
      <td>30</td>
      <td>3000</td>
      <td>Friday</td>
      <td>Sunshine and clouds mixed. High 81F. Winds SW ...</td>
      <td>16</td>
      <td>P Cloudy</td>
      <td>Partly Cloudy</td>
      <td>Partly Cloudy</td>
      <td>20</td>
      <td></td>
      <td>rain</td>
      <td>0</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>53</td>
      <td>Mix of sun and clouds</td>
      <td></td>
      <td></td>
      <td>0</td>
      <td></td>
      <td>Partly</td>
      <td>Cloudy</td>
      <td></td>
      <td>81</td>
      <td>High 81F.</td>
      <td>0</td>
      <td>No thunder</td>
      <td>Very High</td>
      <td>8</td>
      <td>8.35</td>
      <td>0</td>
      <td>D17:DA14:X3000300034:S300032:TH81:W10R03</td>
      <td>58</td>
      <td>234</td>
      <td>SW</td>
      <td>Winds SW at 10 to 15 mph.</td>
      <td>10</td>
      <td>wx1100</td>
      <td>Friday</td>
      <td>1460664024</td>
      <td>1461322800</td>
      <td>2016-04-22T07:00:00-0400</td>
      <td>Full Moon</td>
      <td>F</td>
      <td>15</td>
      <td>81</td>
      <td>59</td>
      <td>2016-04-22T20:27:24-0400</td>
      <td>2016-04-22T06:58:49-0400</td>
      <td>Times of sun and clouds. Highs in the low 80s ...</td>
      <td></td>
      <td>Friday night</td>
      <td>38</td>
      <td>N</td>
      <td>Friday night</td>
      <td>1461366000</td>
      <td>2016-04-22T19:00:00-0400</td>
      <td></td>
      <td>None</td>
      <td>74</td>
      <td>29</td>
      <td>2900</td>
      <td>Friday night</td>
      <td>Partly cloudy. Low 59F. Winds SW at 5 to 10 mph.</td>
      <td>17</td>
      <td>P Cloudy</td>
      <td>Partly Cloudy</td>
      <td>Partly Cloudy</td>
      <td>20</td>
      <td></td>
      <td>rain</td>
      <td>0</td>
      <td>None</td>
      <td>None</td>
      <td>66</td>
      <td>Partly cloudy</td>
      <td></td>
      <td></td>
      <td>0</td>
      <td></td>
      <td>Partly</td>
      <td>Cloudy</td>
      <td></td>
      <td>59</td>
      <td>Low 59F.</td>
      <td>0</td>
      <td>No thunder</td>
      <td>Low</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>D18:DA15:X3000300043:S300042:TL59:W10R02</td>
      <td>60</td>
      <td>219</td>
      <td>SW</td>
      <td>Winds SW at 5 to 10 mph.</td>
      <td>7</td>
      <td>wx1600</td>
      <td>9</td>
      <td>0</td>
      <td>None</td>
      <td>None</td>
      <td></td>
      <td></td>
      <td>0</td>
      <td></td>
      <td>None</td>
      <td>2016-04-22T06:32:46-0400</td>
      <td>2016-04-22T19:55:50-0400</td>
      <td>None</td>
    </tr>
    <tr>
      <th>9</th>
      <td>None</td>
      <td>None</td>
      <td>fod_long_range_daily</td>
      <td></td>
      <td>Saturday</td>
      <td>27</td>
      <td>D</td>
      <td>Saturday</td>
      <td>1461409200</td>
      <td>2016-04-23T07:00:00-0400</td>
      <td>Very Good</td>
      <td>9</td>
      <td>80</td>
      <td>34</td>
      <td>3400</td>
      <td>Saturday</td>
      <td>Mostly sunny skies. High 82F. Winds WSW at 5 t...</td>
      <td>18</td>
      <td>M Sunny</td>
      <td>Mostly Sunny</td>
      <td>Mostly Sunny</td>
      <td>10</td>
      <td></td>
      <td>rain</td>
      <td>0</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>54</td>
      <td>Plenty of sun</td>
      <td></td>
      <td></td>
      <td>0</td>
      <td></td>
      <td>Mostly</td>
      <td>Sunny</td>
      <td></td>
      <td>82</td>
      <td>High 82F.</td>
      <td>0</td>
      <td>No thunder</td>
      <td>Very High</td>
      <td>8</td>
      <td>8.40</td>
      <td>0</td>
      <td>D19:DA16:X3400300032:S340033:TH82:W11R02</td>
      <td>60</td>
      <td>245</td>
      <td>WSW</td>
      <td>Winds WSW at 5 to 10 mph.</td>
      <td>7</td>
      <td>wx1000</td>
      <td>Saturday</td>
      <td>1460664024</td>
      <td>1461409200</td>
      <td>2016-04-23T07:00:00-0400</td>
      <td>Waning Gibbous</td>
      <td>WNG</td>
      <td>16</td>
      <td>82</td>
      <td>59</td>
      <td>2016-04-23T21:21:50-0400</td>
      <td>2016-04-23T07:33:50-0400</td>
      <td>Plenty of sun. Highs in the low 80s and lows i...</td>
      <td></td>
      <td>Saturday night</td>
      <td>17</td>
      <td>N</td>
      <td>Saturday night</td>
      <td>1461452400</td>
      <td>2016-04-23T19:00:00-0400</td>
      <td></td>
      <td>None</td>
      <td>74</td>
      <td>33</td>
      <td>3300</td>
      <td>Saturday night</td>
      <td>Mainly clear. Low 59F. Winds light and variable.</td>
      <td>19</td>
      <td>M Clear</td>
      <td>Mostly Clear</td>
      <td>Mostly Clear</td>
      <td>20</td>
      <td></td>
      <td>rain</td>
      <td>0</td>
      <td>None</td>
      <td>None</td>
      <td>68</td>
      <td>A few clouds</td>
      <td></td>
      <td></td>
      <td>0</td>
      <td></td>
      <td>Mostly</td>
      <td>Clear</td>
      <td></td>
      <td>59</td>
      <td>Low 59F.</td>
      <td>0</td>
      <td>No thunder</td>
      <td>Low</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>D20:DA17:X3400320042:S340041:TL59:W9902</td>
      <td>60</td>
      <td>226</td>
      <td>SW</td>
      <td>Winds light and variable.</td>
      <td>5</td>
      <td>wx1500</td>
      <td>10</td>
      <td>0</td>
      <td>None</td>
      <td>None</td>
      <td></td>
      <td></td>
      <td>0</td>
      <td></td>
      <td>None</td>
      <td>2016-04-23T06:31:32-0400</td>
      <td>2016-04-23T19:56:40-0400</td>
      <td>None</td>
    </tr>
    <tr>
      <th>10</th>
      <td>None</td>
      <td>None</td>
      <td>fod_long_range_daily</td>
      <td></td>
      <td>Sunday</td>
      <td>13</td>
      <td>D</td>
      <td>Sunday</td>
      <td>1461495600</td>
      <td>2016-04-24T07:00:00-0400</td>
      <td>Very Good</td>
      <td>9</td>
      <td>79</td>
      <td>32</td>
      <td>3200</td>
      <td>Sunday</td>
      <td>Sunny. High 81F. Winds WSW at 5 to 10 mph.</td>
      <td>20</td>
      <td>Sunny</td>
      <td>Sunny</td>
      <td>Sunny</td>
      <td>10</td>
      <td></td>
      <td>rain</td>
      <td>0</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>51</td>
      <td>Sunshine</td>
      <td></td>
      <td></td>
      <td>0</td>
      <td></td>
      <td>Sunny</td>
      <td></td>
      <td></td>
      <td>81</td>
      <td>High 81F.</td>
      <td>0</td>
      <td>No thunder</td>
      <td>Very High</td>
      <td>8</td>
      <td>8.45</td>
      <td>0</td>
      <td>D21:DA04:X3200320032:S320034:TH81:W11R02</td>
      <td>60</td>
      <td>250</td>
      <td>WSW</td>
      <td>Winds WSW at 5 to 10 mph.</td>
      <td>7</td>
      <td>wx1000</td>
      <td>Sunday</td>
      <td>1460664024</td>
      <td>1461495600</td>
      <td>2016-04-24T07:00:00-0400</td>
      <td>Waning Gibbous</td>
      <td>WNG</td>
      <td>17</td>
      <td>81</td>
      <td>57</td>
      <td>2016-04-24T22:15:01-0400</td>
      <td>2016-04-24T08:11:01-0400</td>
      <td>Sunshine. Highs in the low 80s and lows in the...</td>
      <td></td>
      <td>Sunday night</td>
      <td>24</td>
      <td>N</td>
      <td>Sunday night</td>
      <td>1461538800</td>
      <td>2016-04-24T19:00:00-0400</td>
      <td></td>
      <td>None</td>
      <td>73</td>
      <td>33</td>
      <td>3300</td>
      <td>Sunday night</td>
      <td>A few clouds from time to time. Low 57F. Winds...</td>
      <td>21</td>
      <td>M Clear</td>
      <td>Mostly Clear</td>
      <td>Mostly Clear</td>
      <td>20</td>
      <td></td>
      <td>rain</td>
      <td>0</td>
      <td>None</td>
      <td>None</td>
      <td>67</td>
      <td>Mostly clear</td>
      <td></td>
      <td></td>
      <td>0</td>
      <td></td>
      <td>Mostly</td>
      <td>Clear</td>
      <td></td>
      <td>57</td>
      <td>Low 57F.</td>
      <td>0</td>
      <td>No thunder</td>
      <td>Low</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>D22:DA05:X3400340042:S340042:TL57:W08R02</td>
      <td>59</td>
      <td>190</td>
      <td>S</td>
      <td>Winds S at 5 to 10 mph.</td>
      <td>6</td>
      <td>wx1500</td>
      <td>11</td>
      <td>0</td>
      <td>None</td>
      <td>None</td>
      <td></td>
      <td></td>
      <td>0</td>
      <td></td>
      <td>None</td>
      <td>2016-04-24T06:30:19-0400</td>
      <td>2016-04-24T19:57:30-0400</td>
      <td>None</td>
    </tr>
  </tbody>
</table>
</div>
</div>

</div>

</div>
</div>

</div>
<div class="cell border-box-sizing text_cell rendered"><div class="prompt input_prompt">
</div><div class="inner_cell">
<div class="text_cell_render border-box-sizing rendered_html">
<p>Of course, if we weren't in a notebook, we probably wouldn't want to do this. Rather, we'd want to filter the DataFrame or the original JSON down to whatever values we needed in our application. Let's do a bit of that now.</p>

</div>
</div>
</div>
<div class="cell border-box-sizing text_cell rendered"><div class="prompt input_prompt">
</div><div class="inner_cell">
<div class="text_cell_render border-box-sizing rendered_html">
<h2 id="Look-at-some-specific-columns">Look at some specific columns<a class="anchor-link" href="#Look-at-some-specific-columns">&#182;</a></h2>
</div>
</div>
</div>
<div class="cell border-box-sizing text_cell rendered"><div class="prompt input_prompt">
</div><div class="inner_cell">
<div class="text_cell_render border-box-sizing rendered_html">
<p>Now that we have an idea of all the available columns, let's dive into a few.</p>
<p>One of the columns appears to be a human readable forecast. Before we show it, let's make sure pandas doesn't ellipsize the text.</p>

</div>
</div>
</div>
<div class="cell border-box-sizing code_cell rendered">
<div class="input">
<div class="prompt input_prompt">In&nbsp;[15]:</div>
<div class="inner_cell">
    <div class="input_area">
<div class=" highlight hl-ipython3"><pre><span></span><span class="n">pd</span><span class="o">.</span><span class="n">options</span><span class="o">.</span><span class="n">display</span><span class="o">.</span><span class="n">max_colwidth</span> <span class="o">=</span> <span class="mi">125</span>
</pre></div>

    </div>

</div>
</div>

</div>
<div class="cell border-box-sizing text_cell rendered"><div class="prompt input_prompt">
</div><div class="inner_cell">
<div class="text_cell_render border-box-sizing rendered_html">
<p>Now we can look at the narrative along side the day it describes.</p>

</div>
</div>
</div>
<div class="cell border-box-sizing code_cell rendered">
<div class="input">
<div class="prompt input_prompt">In&nbsp;[16]:</div>
<div class="inner_cell">
    <div class="input_area">
<div class=" highlight hl-ipython3"><pre><span></span><span class="n">df</span><span class="p">[[</span><span class="s1">&#39;day.alt_daypart_name&#39;</span><span class="p">,</span> <span class="s1">&#39;narrative&#39;</span><span class="p">]]</span>
</pre></div>

    </div>

</div>
</div>

<div class="output_wrapper">
<div class="output">

<div class="output_area">

    <div class="prompt output_prompt">Out[16]:</div>

<div class="output_html rendered_html output_subarea output_execute_result">
<div>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>day.alt_daypart_name</th>
      <th>narrative</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>NaN</td>
      <td>Partly cloudy. Lows overnight in the low 40s.</td>
    </tr>
    <tr>
      <th>1</th>
      <td>Friday</td>
      <td>Mix of sun and clouds. Highs in the upper 60s and lows in the upper 30s.</td>
    </tr>
    <tr>
      <th>2</th>
      <td>Saturday</td>
      <td>Times of sun and clouds. Highs in the low 70s and lows in the low 40s.</td>
    </tr>
    <tr>
      <th>3</th>
      <td>Sunday</td>
      <td>Abundant sunshine. Highs in the low 70s and lows in the mid 40s.</td>
    </tr>
    <tr>
      <th>4</th>
      <td>Monday</td>
      <td>Sunny. Highs in the low 80s and lows in the mid 50s.</td>
    </tr>
    <tr>
      <th>5</th>
      <td>Tuesday</td>
      <td>Partly cloudy. Highs in the low 80s and lows in the low 50s.</td>
    </tr>
    <tr>
      <th>6</th>
      <td>Wednesday</td>
      <td>Times of sun and clouds. Highs in the upper 70s and lows in the low 50s.</td>
    </tr>
    <tr>
      <th>7</th>
      <td>Thursday</td>
      <td>Sunshine. Highs in the low 80s and lows in the mid 50s.</td>
    </tr>
    <tr>
      <th>8</th>
      <td>Friday</td>
      <td>Times of sun and clouds. Highs in the low 80s and lows in the upper 50s.</td>
    </tr>
    <tr>
      <th>9</th>
      <td>Saturday</td>
      <td>Plenty of sun. Highs in the low 80s and lows in the upper 50s.</td>
    </tr>
    <tr>
      <th>10</th>
      <td>Sunday</td>
      <td>Sunshine. Highs in the low 80s and lows in the upper 50s.</td>
    </tr>
  </tbody>
</table>
</div>
</div>

</div>

</div>
</div>

</div>
<div class="cell border-box-sizing text_cell rendered"><div class="prompt input_prompt">
</div><div class="inner_cell">
<div class="text_cell_render border-box-sizing rendered_html">
<p>There's a few mentions of the word <code>golf</code> in the big table columns. Let's find those columns in particular.</p>

</div>
</div>
</div>
<div class="cell border-box-sizing code_cell rendered">
<div class="input">
<div class="prompt input_prompt">In&nbsp;[17]:</div>
<div class="inner_cell">
    <div class="input_area">
<div class=" highlight hl-ipython3"><pre><span></span><span class="n">df</span><span class="o">.</span><span class="n">columns</span><span class="p">[</span><span class="n">df</span><span class="o">.</span><span class="n">columns</span><span class="o">.</span><span class="n">str</span><span class="o">.</span><span class="n">contains</span><span class="p">(</span><span class="s1">&#39;golf&#39;</span><span class="p">)]</span>
</pre></div>

    </div>

</div>
</div>

<div class="output_wrapper">
<div class="output">

<div class="output_area">

    <div class="prompt output_prompt">Out[17]:</div>

<div class="output_text output_subarea output_execute_result">
<pre>Index([&#39;day.golf_category&#39;, &#39;day.golf_index&#39;, &#39;night.golf_category&#39;,
       &#39;night.golf_index&#39;],
      dtype=&#39;object&#39;)</pre>
</div>

</div>

</div>
</div>

</div>
<div class="cell border-box-sizing text_cell rendered"><div class="prompt input_prompt">
</div><div class="inner_cell">
<div class="text_cell_render border-box-sizing rendered_html">
<p>Let's look at those alongside the day names.</p>

</div>
</div>
</div>
<div class="cell border-box-sizing code_cell rendered">
<div class="input">
<div class="prompt input_prompt">In&nbsp;[18]:</div>
<div class="inner_cell">
    <div class="input_area">
<div class=" highlight hl-ipython3"><pre><span></span><span class="n">df</span><span class="p">[[</span><span class="s1">&#39;day.alt_daypart_name&#39;</span><span class="p">]</span> <span class="o">+</span> <span class="n">df</span><span class="o">.</span><span class="n">columns</span><span class="p">[</span><span class="n">df</span><span class="o">.</span><span class="n">columns</span><span class="o">.</span><span class="n">str</span><span class="o">.</span><span class="n">contains</span><span class="p">(</span><span class="s1">&#39;golf&#39;</span><span class="p">)]</span><span class="o">.</span><span class="n">tolist</span><span class="p">()]</span>
</pre></div>

    </div>

</div>
</div>

<div class="output_wrapper">
<div class="output">

<div class="output_area">

    <div class="prompt output_prompt">Out[18]:</div>

<div class="output_html rendered_html output_subarea output_execute_result">
<div>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>day.alt_daypart_name</th>
      <th>day.golf_category</th>
      <th>day.golf_index</th>
      <th>night.golf_category</th>
      <th>night.golf_index</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td></td>
      <td>None</td>
    </tr>
    <tr>
      <th>1</th>
      <td>Friday</td>
      <td>Very Good</td>
      <td>9</td>
      <td></td>
      <td>None</td>
    </tr>
    <tr>
      <th>2</th>
      <td>Saturday</td>
      <td>Excellent</td>
      <td>10</td>
      <td></td>
      <td>None</td>
    </tr>
    <tr>
      <th>3</th>
      <td>Sunday</td>
      <td>Excellent</td>
      <td>10</td>
      <td></td>
      <td>None</td>
    </tr>
    <tr>
      <th>4</th>
      <td>Monday</td>
      <td>Very Good</td>
      <td>9</td>
      <td></td>
      <td>None</td>
    </tr>
    <tr>
      <th>5</th>
      <td>Tuesday</td>
      <td>Very Good</td>
      <td>9</td>
      <td></td>
      <td>None</td>
    </tr>
    <tr>
      <th>6</th>
      <td>Wednesday</td>
      <td>Excellent</td>
      <td>10</td>
      <td></td>
      <td>None</td>
    </tr>
    <tr>
      <th>7</th>
      <td>Thursday</td>
      <td>Very Good</td>
      <td>9</td>
      <td></td>
      <td>None</td>
    </tr>
    <tr>
      <th>8</th>
      <td>Friday</td>
      <td>Very Good</td>
      <td>9</td>
      <td></td>
      <td>None</td>
    </tr>
    <tr>
      <th>9</th>
      <td>Saturday</td>
      <td>Very Good</td>
      <td>9</td>
      <td></td>
      <td>None</td>
    </tr>
    <tr>
      <th>10</th>
      <td>Sunday</td>
      <td>Very Good</td>
      <td>9</td>
      <td></td>
      <td>None</td>
    </tr>
  </tbody>
</table>
</div>
</div>

</div>

</div>
</div>

</div>
<div class="cell border-box-sizing text_cell rendered"><div class="prompt input_prompt">
</div><div class="inner_cell">
<div class="text_cell_render border-box-sizing rendered_html">
<p>The day time golf category and index are interesting. Night golf is ... well ... unexplained. &#127771;</p>

</div>
</div>
</div>
<div class="cell border-box-sizing text_cell rendered"><div class="prompt input_prompt">
</div><div class="inner_cell">
<div class="text_cell_render border-box-sizing rendered_html">
<p>How about temperatures? Let's get a summary of the values for the next ten days.</p>

</div>
</div>
</div>
<div class="cell border-box-sizing code_cell rendered">
<div class="input">
<div class="prompt input_prompt">In&nbsp;[19]:</div>
<div class="inner_cell">
    <div class="input_area">
<div class=" highlight hl-ipython3"><pre><span></span><span class="n">df</span><span class="p">[[</span><span class="s1">&#39;max_temp&#39;</span><span class="p">,</span> <span class="s1">&#39;min_temp&#39;</span><span class="p">]]</span><span class="o">.</span><span class="n">describe</span><span class="p">()</span>
</pre></div>

    </div>

</div>
</div>

<div class="output_wrapper">
<div class="output">

<div class="output_area">

    <div class="prompt output_prompt">Out[19]:</div>

<div class="output_html rendered_html output_subarea output_execute_result">
<div>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>max_temp</th>
      <th>min_temp</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>count</th>
      <td>10.000000</td>
      <td>11.000000</td>
    </tr>
    <tr>
      <th>mean</th>
      <td>77.400000</td>
      <td>50.181818</td>
    </tr>
    <tr>
      <th>std</th>
      <td>5.274677</td>
      <td>7.665744</td>
    </tr>
    <tr>
      <th>min</th>
      <td>67.000000</td>
      <td>39.000000</td>
    </tr>
    <tr>
      <th>25%</th>
      <td>74.000000</td>
      <td>43.000000</td>
    </tr>
    <tr>
      <th>50%</th>
      <td>80.000000</td>
      <td>52.000000</td>
    </tr>
    <tr>
      <th>75%</th>
      <td>81.000000</td>
      <td>56.500000</td>
    </tr>
    <tr>
      <th>max</th>
      <td>82.000000</td>
      <td>59.000000</td>
    </tr>
  </tbody>
</table>
</div>
</div>

</div>

</div>
</div>

</div>
<div class="cell border-box-sizing text_cell rendered"><div class="prompt input_prompt">
</div><div class="inner_cell">
<div class="text_cell_render border-box-sizing rendered_html">
<h2 id="Try-another-endpoint">Try another endpoint<a class="anchor-link" href="#Try-another-endpoint">&#182;</a></h2><p>So far we've poked at the 10-day forecast resource. Let's try another just to see how similar / different it is. Here we'll fetch historical observations for the same location.</p>

</div>
</div>
</div>
<div class="cell border-box-sizing code_cell rendered">
<div class="input">
<div class="prompt input_prompt">In&nbsp;[20]:</div>
<div class="inner_cell">
    <div class="input_area">
<div class=" highlight hl-ipython3"><pre><span></span><span class="n">resp</span> <span class="o">=</span> <span class="n">requests</span><span class="o">.</span><span class="n">get</span><span class="p">(</span><span class="n">url</span><span class="o">+</span><span class="s1">&#39;/observations/timeseries/24hour&#39;</span><span class="p">,</span> <span class="n">auth</span><span class="o">=</span><span class="n">auth</span><span class="p">,</span> <span class="n">params</span><span class="o">=</span><span class="n">params</span><span class="p">)</span>
<span class="n">resp</span><span class="o">.</span><span class="n">raise_for_status</span><span class="p">()</span>
<span class="n">body</span> <span class="o">=</span> <span class="n">resp</span><span class="o">.</span><span class="n">json</span><span class="p">()</span>
<span class="n">body</span><span class="o">.</span><span class="n">keys</span><span class="p">()</span>
</pre></div>

    </div>

</div>
</div>

<div class="output_wrapper">
<div class="output">

<div class="output_area">

    <div class="prompt output_prompt">Out[20]:</div>

<div class="output_text output_subarea output_execute_result">
<pre>dict_keys([&#39;observations&#39;, &#39;metadata&#39;])</pre>
</div>

</div>

</div>
</div>

</div>
<div class="cell border-box-sizing text_cell rendered"><div class="prompt input_prompt">
</div><div class="inner_cell">
<div class="text_cell_render border-box-sizing rendered_html">
<p>This time, the key of interest is <code>observations</code>.</p>

</div>
</div>
</div>
<div class="cell border-box-sizing code_cell rendered">
<div class="input">
<div class="prompt input_prompt">In&nbsp;[21]:</div>
<div class="inner_cell">
    <div class="input_area">
<div class=" highlight hl-ipython3"><pre><span></span><span class="n">obs</span> <span class="o">=</span> <span class="n">pd</span><span class="o">.</span><span class="n">io</span><span class="o">.</span><span class="n">json</span><span class="o">.</span><span class="n">json_normalize</span><span class="p">(</span><span class="n">body</span><span class="p">[</span><span class="s1">&#39;observations&#39;</span><span class="p">])</span>
</pre></div>

    </div>

</div>
</div>

</div>
<div class="cell border-box-sizing text_cell rendered"><div class="prompt input_prompt">
</div><div class="inner_cell">
<div class="text_cell_render border-box-sizing rendered_html">
<p>Fewer columns this time. Let's poke at the <code>blunt_phrase</code> and `valid_time_gmt.</p>

</div>
</div>
</div>
<div class="cell border-box-sizing code_cell rendered">
<div class="input">
<div class="prompt input_prompt">In&nbsp;[22]:</div>
<div class="inner_cell">
    <div class="input_area">
<div class=" highlight hl-ipython3"><pre><span></span><span class="n">obs</span><span class="o">.</span><span class="n">columns</span>
</pre></div>

    </div>

</div>
</div>

<div class="output_wrapper">
<div class="output">

<div class="output_area">

    <div class="prompt output_prompt">Out[22]:</div>

<div class="output_text output_subarea output_execute_result">
<pre>Index([&#39;blunt_phrase&#39;, &#39;class&#39;, &#39;clds&#39;, &#39;day_ind&#39;, &#39;dewPt&#39;, &#39;expire_time_gmt&#39;,
       &#39;feels_like&#39;, &#39;gust&#39;, &#39;heat_index&#39;, &#39;icon_extd&#39;, &#39;key&#39;, &#39;max_temp&#39;,
       &#39;min_temp&#39;, &#39;obs_id&#39;, &#39;obs_name&#39;, &#39;precip_hrly&#39;, &#39;precip_total&#39;,
       &#39;pressure&#39;, &#39;pressure_desc&#39;, &#39;pressure_tend&#39;, &#39;qualifier&#39;,
       &#39;qualifier_svrty&#39;, &#39;rh&#39;, &#39;snow_hrly&#39;, &#39;temp&#39;, &#39;terse_phrase&#39;, &#39;uv_desc&#39;,
       &#39;uv_index&#39;, &#39;valid_time_gmt&#39;, &#39;vis&#39;, &#39;wc&#39;, &#39;wdir&#39;, &#39;wdir_cardinal&#39;,
       &#39;wspd&#39;, &#39;wx_icon&#39;, &#39;wx_phrase&#39;],
      dtype=&#39;object&#39;)</pre>
</div>

</div>

</div>
</div>

</div>
<div class="cell border-box-sizing code_cell rendered">
<div class="input">
<div class="prompt input_prompt">In&nbsp;[23]:</div>
<div class="inner_cell">
    <div class="input_area">
<div class=" highlight hl-ipython3"><pre><span></span><span class="n">obs</span><span class="o">.</span><span class="n">valid_time_gmt</span><span class="o">.</span><span class="n">head</span><span class="p">()</span>
</pre></div>

    </div>

</div>
</div>

<div class="output_wrapper">
<div class="output">

<div class="output_area">

    <div class="prompt output_prompt">Out[23]:</div>

<div class="output_text output_subarea output_execute_result">
<pre>0    1460619900
1    1460621100
2    1460622300
3    1460623500
4    1460624700
Name: valid_time_gmt, dtype: int64</pre>
</div>

</div>

</div>
</div>

</div>
<div class="cell border-box-sizing text_cell rendered"><div class="prompt input_prompt">
</div><div class="inner_cell">
<div class="text_cell_render border-box-sizing rendered_html">
<p>We can make the times more human readable. They're seconds since the epoch expressed in UTC.</p>

</div>
</div>
</div>
<div class="cell border-box-sizing code_cell rendered">
<div class="input">
<div class="prompt input_prompt">In&nbsp;[24]:</div>
<div class="inner_cell">
    <div class="input_area">
<div class=" highlight hl-ipython3"><pre><span></span><span class="n">obs</span><span class="p">[</span><span class="s1">&#39;time_utc&#39;</span><span class="p">]</span> <span class="o">=</span> <span class="n">pd</span><span class="o">.</span><span class="n">to_datetime</span><span class="p">(</span><span class="n">obs</span><span class="o">.</span><span class="n">valid_time_gmt</span><span class="p">,</span> <span class="n">unit</span><span class="o">=</span><span class="s1">&#39;s&#39;</span><span class="p">,</span> <span class="n">utc</span><span class="o">=</span><span class="kc">True</span><span class="p">)</span>
</pre></div>

    </div>

</div>
</div>

</div>
<div class="cell border-box-sizing text_cell rendered"><div class="prompt input_prompt">
</div><div class="inner_cell">
<div class="text_cell_render border-box-sizing rendered_html">
<p>Now we can check the summary of the available observations within the last 24 hours. We'll reverse them so that they're sorted newest to oldest.</p>

</div>
</div>
</div>
<div class="cell border-box-sizing code_cell rendered">
<div class="input">
<div class="prompt input_prompt">In&nbsp;[25]:</div>
<div class="inner_cell">
    <div class="input_area">
<div class=" highlight hl-ipython3"><pre><span></span><span class="n">obs</span><span class="p">[[</span><span class="s1">&#39;blunt_phrase&#39;</span><span class="p">,</span> <span class="s1">&#39;time_utc&#39;</span><span class="p">]]</span><span class="o">.</span><span class="n">iloc</span><span class="p">[::</span><span class="o">-</span><span class="mi">1</span><span class="p">]</span>
</pre></div>

    </div>

</div>
</div>

<div class="output_wrapper">
<div class="output">

<div class="output_area">

    <div class="prompt output_prompt">Out[25]:</div>

<div class="output_html rendered_html output_subarea output_execute_result">
<div>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>blunt_phrase</th>
      <th>time_utc</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>35</th>
      <td>Temps slightly below average.</td>
      <td>2016-04-14 19:25:00</td>
    </tr>
    <tr>
      <th>34</th>
      <td>Temps slightly below average.</td>
      <td>2016-04-14 19:05:00</td>
    </tr>
    <tr>
      <th>33</th>
      <td>Temps slightly below average.</td>
      <td>2016-04-14 18:45:00</td>
    </tr>
    <tr>
      <th>32</th>
      <td>Seasonal temperatures.</td>
      <td>2016-04-14 18:25:00</td>
    </tr>
    <tr>
      <th>31</th>
      <td>Temps slightly below average.</td>
      <td>2016-04-14 18:05:00</td>
    </tr>
    <tr>
      <th>30</th>
      <td>Seasonal temperatures.</td>
      <td>2016-04-14 17:45:00</td>
    </tr>
    <tr>
      <th>29</th>
      <td>Seasonal temperatures.</td>
      <td>2016-04-14 17:25:00</td>
    </tr>
    <tr>
      <th>28</th>
      <td>Seasonal temperatures.</td>
      <td>2016-04-14 17:05:00</td>
    </tr>
    <tr>
      <th>27</th>
      <td>Seasonal temperatures.</td>
      <td>2016-04-14 16:45:00</td>
    </tr>
    <tr>
      <th>26</th>
      <td>Seasonal temperatures.</td>
      <td>2016-04-14 16:25:00</td>
    </tr>
    <tr>
      <th>25</th>
      <td>Seasonal temperatures.</td>
      <td>2016-04-14 16:05:00</td>
    </tr>
    <tr>
      <th>24</th>
      <td>Seasonal temperatures.</td>
      <td>2016-04-14 15:45:00</td>
    </tr>
    <tr>
      <th>23</th>
      <td>Seasonal temperatures.</td>
      <td>2016-04-14 15:25:00</td>
    </tr>
    <tr>
      <th>22</th>
      <td>Seasonal temperatures.</td>
      <td>2016-04-14 15:05:00</td>
    </tr>
    <tr>
      <th>21</th>
      <td>Seasonal temperatures.</td>
      <td>2016-04-14 14:45:00</td>
    </tr>
    <tr>
      <th>20</th>
      <td>Seasonal temperatures.</td>
      <td>2016-04-14 14:25:00</td>
    </tr>
    <tr>
      <th>19</th>
      <td>Seasonal temperatures.</td>
      <td>2016-04-14 14:05:00</td>
    </tr>
    <tr>
      <th>18</th>
      <td>Seasonal temperatures.</td>
      <td>2016-04-14 13:45:00</td>
    </tr>
    <tr>
      <th>17</th>
      <td>Seasonal temperatures.</td>
      <td>2016-04-14 13:25:00</td>
    </tr>
    <tr>
      <th>16</th>
      <td>Seasonal temperatures.</td>
      <td>2016-04-14 13:05:00</td>
    </tr>
    <tr>
      <th>15</th>
      <td>Seasonal temperatures.</td>
      <td>2016-04-14 12:45:00</td>
    </tr>
    <tr>
      <th>14</th>
      <td>Seasonal temperatures.</td>
      <td>2016-04-14 12:25:00</td>
    </tr>
    <tr>
      <th>13</th>
      <td>Temps slightly below average.</td>
      <td>2016-04-14 12:05:00</td>
    </tr>
    <tr>
      <th>12</th>
      <td>Temps slightly below average.</td>
      <td>2016-04-14 11:45:00</td>
    </tr>
    <tr>
      <th>11</th>
      <td>Seasonal temperatures.</td>
      <td>2016-04-14 11:25:00</td>
    </tr>
    <tr>
      <th>10</th>
      <td>Patchy fog reported nearby.</td>
      <td>2016-04-14 11:05:00</td>
    </tr>
    <tr>
      <th>9</th>
      <td>Seasonal temperatures.</td>
      <td>2016-04-14 10:45:00</td>
    </tr>
    <tr>
      <th>8</th>
      <td>Seasonal temperatures.</td>
      <td>2016-04-14 10:25:00</td>
    </tr>
    <tr>
      <th>7</th>
      <td>Seasonal temperatures.</td>
      <td>2016-04-14 10:05:00</td>
    </tr>
    <tr>
      <th>6</th>
      <td>Cooler than yesterday.</td>
      <td>2016-04-14 09:45:00</td>
    </tr>
    <tr>
      <th>5</th>
      <td>Cooler than yesterday.</td>
      <td>2016-04-14 09:25:00</td>
    </tr>
    <tr>
      <th>4</th>
      <td>Cooler than yesterday.</td>
      <td>2016-04-14 09:05:00</td>
    </tr>
    <tr>
      <th>3</th>
      <td>Cooler than yesterday.</td>
      <td>2016-04-14 08:45:00</td>
    </tr>
    <tr>
      <th>2</th>
      <td>Cooler than yesterday.</td>
      <td>2016-04-14 08:25:00</td>
    </tr>
    <tr>
      <th>1</th>
      <td>Cooler than yesterday.</td>
      <td>2016-04-14 08:05:00</td>
    </tr>
    <tr>
      <th>0</th>
      <td>Cooler than yesterday.</td>
      <td>2016-04-14 07:45:00</td>
    </tr>
  </tbody>
</table>
</div>
</div>

</div>

</div>
</div>

</div>
<div class="cell border-box-sizing text_cell rendered"><div class="prompt input_prompt">
</div><div class="inner_cell">
<div class="text_cell_render border-box-sizing rendered_html">
<p>&#127804; I guess it's seasonal right now. &#127804;</p>

</div>
</div>
</div>
<div class="cell border-box-sizing text_cell rendered"><div class="prompt input_prompt">
</div><div class="inner_cell">
<div class="text_cell_render border-box-sizing rendered_html">
<h2 id="Go-further">Go further<a class="anchor-link" href="#Go-further">&#182;</a></h2><p>We'll stop here. What we did in this notebook is a prelude to what's possible. Here's some ideas for further experimentation:</p>
<ul>
<li>Write a simple Python function (or functions) that wrap the few lines of request logic needed to query any of the API endpoints.</li>
<li>Funnel observations into a persistent store to collect them over time. Use that historical data to try to build a predictive model (e.g., using scikit-learn).</li>
<li>Combine weather data with data from other sources in domain specific notebooks or applications.</li>
</ul>

</div>
</div>
</div>
