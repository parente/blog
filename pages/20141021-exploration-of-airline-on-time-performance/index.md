---
title: Exploration of Airline On-Time Performance
date: 2014-10-21
excerpt: This post comes from a <a href="https://gist.github.com/parente/7cf287e32dfa49cd6664">sample notebook</a> I created for a <a href="http://www.ibm.com/developerworks/cloud/library/cl-ipy-docker-softlayer-trs/index.html" >developerWorks article about running IPython in Docker on SoftLayer</a >. I had fun toying the data and using <a href="http://web.stanford.edu/~mwaskom/software/seaborn/">Seaborn</a> and <a href="http://cloudant.com">Cloudant</a> for the first time, so I decided to include it here for posterity.
template: notebook.mako
---

<div class="cell border-box-sizing text_cell rendered">
  <div class="prompt input_prompt"></div>
  <div class="inner_cell">
    <div class="text_cell_render border-box-sizing rendered_html">
      <p class="commentary"><i class="fa fa-comment-o"></i> 
        This post comes from a
        <a href="https://gist.github.com/parente/7cf287e32dfa49cd6664"
          >sample notebook</a
        >
        I created for a
        <a
          href="http://www.ibm.com/developerworks/cloud/library/cl-ipy-docker-softlayer-trs/index.html"
          >developerWorks article about running IPython in Docker on
          SoftLayer</a
        >. I had fun toying the data and using
        <a href="http://web.stanford.edu/~mwaskom/software/seaborn/">Seaborn</a>
        and <a href="http://cloudant.com">Cloudant</a> for the first time, so I
        decided to include it here for posterity.
      </p>
      <hr />
      <p>
        In this notebook, we explore a sample of data from the U.S. Department
        of Transportation (US-DOT) Research and Innovative Technology
        Administration (RITA)
        <a href="http://www.rita.dot.gov/bts/about/"
          >Bureau of Transportation Statistics</a
        >
        (BTS). The data comes from the
        <a href="http://www.transtats.bts.gov/Fields.asp?Table_ID=236"
          >On-Time Performance</a
        >
        table:
      </p>
      <blockquote>
        <p>
          This table contains on-time arrival data for non-stop domestic flights
          by major air carriers, and provides such additional items as departure
          and arrival delays, origin and destination airports, flight numbers,
          scheduled and actual departure and arrival times, cancelled or
          diverted flights, taxi-out and taxi-in times, air time, and non-stop
          distance.
        </p>
      </blockquote>
      <h2 id="Questions">
        Questions<a class="anchor-link" href="#Questions">&#182;</a>
      </h2>
      <p>
        For the purposes of this notebook, I have captured a subset of the table
        in a <a href="https://cloudant.com">Cloudant</a> database. We will start
        by connecting to the database and simply looking at the available data.
        Once we understand the content, we will try to answer the following
        questions about flights during the month of June, 2014:
      </p>
      <ol>
        <li>
          What is the distribution of departure delays of at least 15 minutes by
          state? Arrival delays?
        </li>
        <li>
          Is there a tendency of flights from one state to another to experience
          a delay of 15 minutes or more on the arriving end?
        </li>
        <li>How did arrival delay in minutes vary day-by-day?</li>
      </ol>
      <h2 id="Connect-to-Cloudant">
        Connect to Cloudant<a class="anchor-link" href="#Connect-to-Cloudant"
          >&#182;</a
        >
      </h2>
      <p>
        To get to the data, we can use a
        <a href="https://cloudant.com/python/">Cloudant client for Python</a>.
        We'll can install the official client by shelling out to
        <code>bash</code> and running a <code>pip</code> command right here.
      </p>
    </div>
  </div>
</div>
<div class="cell border-box-sizing code_cell rendered">
  <div class="input">
    <div class="prompt input_prompt">In&nbsp;[1]:</div>
    <div class="inner_cell">
      <div class="input_area">
        <div class="highlight hl-ipython3">
          <pre><span></span><span class="err">!</span><span class="n">pip</span> <span class="n">install</span> <span class="n">cloudant</span>
</pre>
        </div>
      </div>
    </div>
  </div>

  <div class="output_wrapper">
    <div class="output">
      <div class="output_area">
        <div class="prompt"></div>

        <div class="output_subarea output_stream output_stdout output_text">
          <pre>

Requirement already satisfied (use --upgrade to upgrade): cloudant in /usr/local/lib/python2.7/dist-packages
Requirement already satisfied (use --upgrade to upgrade): requests-futures==0.9.4 in /usr/local/lib/python2.7/dist-packages (from cloudant)
Requirement already satisfied (use --upgrade to upgrade): requests&gt;=1.2.0 in /usr/lib/python2.7/dist-packages (from requests-futures==0.9.4-&gt;cloudant)
Requirement already satisfied (use --upgrade to upgrade): futures&gt;=2.1.3 in /usr/local/lib/python2.7/dist-packages (from requests-futures==0.9.4-&gt;cloudant)
Cleaning up...

</pre
          >
        </div>
      </div>
    </div>
  </div>
</div>
<div class="cell border-box-sizing text_cell rendered">
  <div class="prompt input_prompt"></div>
  <div class="inner_cell">
    <div class="text_cell_render border-box-sizing rendered_html">
      <p>
        Now we'll import the <code>cloudant</code> package we just installed and
        use it to connect to the read-only
        <code>rita_transtats_2014_06</code> database in the
        <code>parente</code> user account.
      </p>
    </div>
  </div>
</div>
<div class="cell border-box-sizing code_cell rendered">
  <div class="input">
    <div class="prompt input_prompt">In&nbsp;[2]:</div>
    <div class="inner_cell">
      <div class="input_area">
        <div class="highlight hl-ipython3">
          <pre><span></span><span class="kn">import</span> <span class="nn">cloudant</span>
</pre>
        </div>
      </div>
    </div>
  </div>
</div>
<div class="cell border-box-sizing code_cell rendered">
  <div class="input">
    <div class="prompt input_prompt">In&nbsp;[3]:</div>
    <div class="inner_cell">
      <div class="input_area">
        <div class="highlight hl-ipython3">
          <pre><span></span><span class="n">account</span> <span class="o">=</span> <span class="n">cloudant</span><span class="o">.</span><span class="n">Account</span><span class="p">(</span><span class="s1">&#39;parente&#39;</span><span class="p">)</span>
</pre>
        </div>
      </div>
    </div>
  </div>
</div>
<div class="cell border-box-sizing code_cell rendered">
  <div class="input">
    <div class="prompt input_prompt">In&nbsp;[4]:</div>
    <div class="inner_cell">
      <div class="input_area">
        <div class="highlight hl-ipython3">
          <pre><span></span><span class="n">database</span> <span class="o">=</span> <span class="n">account</span><span class="o">.</span><span class="n">database</span><span class="p">(</span><span class="s1">&#39;rita_transtats_2014_06&#39;</span><span class="p">)</span>
</pre>
        </div>
      </div>
    </div>
  </div>
</div>
<div class="cell border-box-sizing text_cell rendered">
  <div class="prompt input_prompt"></div>
  <div class="inner_cell">
    <div class="text_cell_render border-box-sizing rendered_html">
      <p>
        The <code>cloudant</code> package builds on the popular Python
        <a href="http://docs.python-requests.org/en/latest/">requests</a>
        package. Almost every object that comes back from the API is a subclass
        of a <code>requests</code> class. This means we can perform a HTTP GET
        against the database and get the JSON body of the response with a couple
        method calls.
      </p>
    </div>
  </div>
</div>
<div class="cell border-box-sizing code_cell rendered">
  <div class="input">
    <div class="prompt input_prompt">In&nbsp;[5]:</div>
    <div class="inner_cell">
      <div class="input_area">
        <div class="highlight hl-ipython3">
          <pre><span></span><span class="n">database</span><span class="o">.</span><span class="n">get</span><span class="p">()</span><span class="o">.</span><span class="n">json</span><span class="p">()</span>
</pre>
        </div>
      </div>
    </div>
  </div>

  <div class="output_wrapper">
    <div class="output">
      <div class="output_area">
        <div class="prompt output_prompt">Out[5]:</div>

        <div class="output_text output_subarea output_execute_result">
          <pre>

{u&#39;compact_running&#39;: False,
u&#39;db_name&#39;: u&#39;rita_transtats_2014_06&#39;,
u&#39;disk_format_version&#39;: 5,
u&#39;disk_size&#39;: 160707408,
u&#39;doc_count&#39;: 502500,
u&#39;doc_del_count&#39;: 0,
u&#39;instance_start_time&#39;: u&#39;0&#39;,
u&#39;other&#39;: {u&#39;data_size&#39;: 265247850},
u&#39;purge_seq&#39;: 0,
u&#39;update_seq&#39;: u&#39;502516-g1AAAADveJzLYWBgYMlgTmGQT0lKzi9KdUhJMtJLykxPyilN1UvOyS9NScwr0ctLLckBKmRKZEiy\_\_\_\_f1YSA-PrcKJ1JTkAyaR6qMZX84nWmMcCJBkagBRQ736w5mgSNR-AaIbYvDgLACDLUQs&#39;}</pre
          >

</div>
</div>
</div>

  </div>
</div>
<div class="cell border-box-sizing text_cell rendered">
  <div class="prompt input_prompt"></div>
  <div class="inner_cell">
    <div class="text_cell_render border-box-sizing rendered_html">
      <p>
        From the above, we can see the database contains roughly 500,000
        documents. We can grab a couple from the database to inspect locally.
      </p>
    </div>
  </div>
</div>
<div class="cell border-box-sizing code_cell rendered">
  <div class="input">
    <div class="prompt input_prompt">In&nbsp;[6]:</div>
    <div class="inner_cell">
      <div class="input_area">
        <div class="highlight hl-ipython3">
          <pre><span></span><span class="n">items</span> <span class="o">=</span> <span class="p">[]</span>
<span class="k">for</span> <span class="n">i</span><span class="p">,</span> <span class="n">item</span> <span class="ow">in</span> <span class="nb">enumerate</span><span class="p">(</span><span class="n">database</span><span class="o">.</span><span class="n">all_docs</span><span class="p">(</span><span class="n">params</span><span class="o">=</span><span class="p">{</span><span class="s1">&#39;include_docs&#39;</span> <span class="p">:</span> <span class="kc">True</span><span class="p">})):</span>
    <span class="k">if</span> <span class="n">i</span> <span class="o">&gt;</span> <span class="mi">1</span><span class="p">:</span> <span class="k">break</span>
    <span class="n">items</span><span class="o">.</span><span class="n">append</span><span class="p">(</span><span class="n">item</span><span class="p">)</span>
<span class="nb">print</span> <span class="n">items</span>
</pre>
        </div>
      </div>
    </div>
  </div>

  <div class="output_wrapper">
    <div class="output">
      <div class="output_area">
        <div class="prompt"></div>

        <div class="output_subarea output_stream output_stdout output_text">
          <pre>

[{u&#39;value&#39;: {u&#39;rev&#39;: u&#39;1-40fc15f608f95f0428e2e9d6b468e483&#39;}, u&#39;id&#39;: u&#39;04da0d01eb0f15d5c56eb1399a000a35&#39;, u&#39;key&#39;: u&#39;04da0d01eb0f15d5c56eb1399a000a35&#39;, u&#39;doc&#39;: {u&#39;DISTANCE&#39;: 1947.0, u&#39;DEST_AIRPORT_ID&#39;: 12892, u&#39;ARR_DEL15&#39;: 0.0, u&#39;ORIGIN_STATE_ABR&#39;: u&#39;GA&#39;, u&#39;_rev&#39;: u&#39;1-40fc15f608f95f0428e2e9d6b468e483&#39;, u&#39;ARR_DELAY_NEW&#39;: 0.0, u&#39;UNIQUE_CARRIER&#39;: u&#39;DL&#39;, u&#39;ORIGIN_AIRPORT_ID&#39;: 10397, u&#39;DISTANCE_GROUP&#39;: 8, u&#39;DEP_DEL15&#39;: 0.0, u&#39;_id&#39;: u&#39;04da0d01eb0f15d5c56eb1399a000a35&#39;, u&#39;DEST_STATE_ABR&#39;: u&#39;CA&#39;, u&#39;DEP_DELAY_NEW&#39;: 0.0, u&#39;FL_DATE&#39;: u&#39;2014-06-30&#39;}}, {u&#39;value&#39;: {u&#39;rev&#39;: u&#39;1-4dd24d56dc537210f49fe327c7773178&#39;}, u&#39;id&#39;: u&#39;04da0d01eb0f15d5c56eb1399a001198&#39;, u&#39;key&#39;: u&#39;04da0d01eb0f15d5c56eb1399a001198&#39;, u&#39;doc&#39;: {u&#39;DISTANCE&#39;: 282.0, u&#39;DEST_AIRPORT_ID&#39;: 13487, u&#39;ARR_DEL15&#39;: 0.0, u&#39;ORIGIN_STATE_ABR&#39;: u&#39;NE&#39;, u&#39;_rev&#39;: u&#39;1-4dd24d56dc537210f49fe327c7773178&#39;, u&#39;ARR_DELAY_NEW&#39;: 0.0, u&#39;UNIQUE_CARRIER&#39;: u&#39;DL&#39;, u&#39;ORIGIN_AIRPORT_ID&#39;: 13871, u&#39;DISTANCE_GROUP&#39;: 2, u&#39;DEP_DEL15&#39;: 0.0, u&#39;_id&#39;: u&#39;04da0d01eb0f15d5c56eb1399a001198&#39;, u&#39;DEST_STATE_ABR&#39;: u&#39;MN&#39;, u&#39;DEP_DELAY_NEW&#39;: 0.0, u&#39;FL_DATE&#39;: u&#39;2014-06-30&#39;}}]

</pre
          >
        </div>
      </div>
    </div>
  </div>
</div>
<div class="cell border-box-sizing text_cell rendered">
  <div class="prompt input_prompt"></div>
  <div class="inner_cell">
    <div class="text_cell_render border-box-sizing rendered_html">
      <p>
        The dictionary format is hard to read and contains metadata from
        Cloudant that we don't care about. Let's use the
        <code>pandas</code> package to put the data in a tabular, HTML format
        instead.
      </p>
    </div>
  </div>
</div>
<div class="cell border-box-sizing code_cell rendered">
  <div class="input">
    <div class="prompt input_prompt">In&nbsp;[7]:</div>
    <div class="inner_cell">
      <div class="input_area">
        <div class="highlight hl-ipython3">
          <pre><span></span><span class="kn">import</span> <span class="nn">pandas</span>
</pre>
        </div>
      </div>
    </div>
  </div>
</div>
<div class="cell border-box-sizing code_cell rendered">
  <div class="input">
    <div class="prompt input_prompt">In&nbsp;[8]:</div>
    <div class="inner_cell">
      <div class="input_area">
        <div class="highlight hl-ipython3">
          <pre><span></span><span class="n">pandas</span><span class="o">.</span><span class="n">DataFrame</span><span class="p">([</span><span class="n">item</span><span class="p">[</span><span class="s1">&#39;doc&#39;</span><span class="p">]</span> <span class="k">for</span> <span class="n">item</span> <span class="ow">in</span> <span class="n">items</span><span class="p">])</span>
</pre>
        </div>
      </div>
    </div>
  </div>

  <div class="output_wrapper">
    <div class="output">
      <div class="output_area">
        <div class="prompt output_prompt">Out[8]:</div>

        <div
          class="output_html rendered_html output_subarea output_execute_result"
        >
          <div style="max-height: 1000px; max-width: 1500px; overflow: auto">
            <table border="1" class="dataframe">
              <thead>
                <tr style="text-align: right">
                  <th></th>
                  <th>ARR_DEL15</th>
                  <th>ARR_DELAY_NEW</th>
                  <th>DEP_DEL15</th>
                  <th>DEP_DELAY_NEW</th>
                  <th>DEST_AIRPORT_ID</th>
                  <th>DEST_STATE_ABR</th>
                  <th>DISTANCE</th>
                  <th>DISTANCE_GROUP</th>
                  <th>FL_DATE</th>
                  <th>ORIGIN_AIRPORT_ID</th>
                  <th>ORIGIN_STATE_ABR</th>
                  <th>UNIQUE_CARRIER</th>
                  <th>_id</th>
                  <th>_rev</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <th>0</th>
                  <td>0</td>
                  <td>0</td>
                  <td>0</td>
                  <td>0</td>
                  <td>12892</td>
                  <td>CA</td>
                  <td>1947</td>
                  <td>8</td>
                  <td>2014-06-30</td>
                  <td>10397</td>
                  <td>GA</td>
                  <td>DL</td>
                  <td>04da0d01eb0f15d5c56eb1399a000a35</td>
                  <td>1-40fc15f608f95f0428e2e9d6b468e483</td>
                </tr>
                <tr>
                  <th>1</th>
                  <td>0</td>
                  <td>0</td>
                  <td>0</td>
                  <td>0</td>
                  <td>13487</td>
                  <td>MN</td>
                  <td>282</td>
                  <td>2</td>
                  <td>2014-06-30</td>
                  <td>13871</td>
                  <td>NE</td>
                  <td>DL</td>
                  <td>04da0d01eb0f15d5c56eb1399a001198</td>
                  <td>1-4dd24d56dc537210f49fe327c7773178</td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>

  </div>
</div>
<div class="cell border-box-sizing text_cell rendered">
  <div class="prompt input_prompt"></div>
  <div class="inner_cell">
    <div class="text_cell_render border-box-sizing rendered_html">
      <p>
        Returning to
        <a href="http://www.transtats.bts.gov/Fields.asp?Table_ID=236"
          >the source of the data</a
        >, we can get definitions for each of these fields.
      </p>
      <dl class="dl-horizontal">
        <dt>ARR_DEL15</dt>
        <dd>Arrival Delay Indicator, 15 Minutes or More (1=Yes)</dd>
        <dt>ARR_DEL15</dt>
        <dd>Arrival Delay Indicator, 15 Minutes or More (1=Yes)</dd>
        <dt>ARR_DELAY_NEW</dt>
        <dd>
          Difference in minutes between scheduled and actual arrival time. Early
          arrivals set to 0.
        </dd>
        <dt>DEP_DEL15</dt>
        <dd>Departure Delay Indicator, 15 Minutes or More (1=Yes)</dd>
        <dt>DEP_DELAY_NEW</dt>
        <dd>
          Difference in minutes between scheduled and actual departure time.
          Early departures set to 0.
        </dd>
        <dt>DEST_AIRPORT_ID</dt>
        <dd>
          Destination Airport, Airport ID. An identification number assigned by
          US DOT to identify a unique airport. Use this field for airport
          analysis across a range of years because an airport can change its
          airport code and airport codes can be reused.
        </dd>
        <dt>DEST_STATE_ABR</dt>
        <dd>Destination Airport, State Code</dd>
        <dt>DISTANCE</dt>
        <dd>Distance between airports (miles)</dd>
        <dt>DISTANCE_GROUP</dt>
        <dd>Distance Intervals, every 250 Miles, for Flight Segment</dd>
        <dt>FL_DATE</dt>
        <dd>Flight Date (yyyymmdd)</dd>
        <dt>ORIGIN_AIRPORT_ID</dt>
        <dd>
          Origin Airport, Airport ID. An identification number assigned by US
          DOT to identify a unique airport. Use this field for airport analysis
          across a range of years because an airport can change its airport code
          and airport codes can be reused.
        </dd>
        <dt>ORIGIN_STATE_ABR</dt>
        <dd>Origin Airport, State Code</dd>
        <dt>UNIQUE_CARRIER</dt>
        <dd>
          Unique Carrier Code. When the same code has been used by multiple
          carriers, a numeric suffix is used for earlier users, for example, PA,
          PA(1), PA(2). Use this field for analysis across a range of years.
        </dd>
      </dl>
      <p>
        For the purposes of the specific questions stated at the top of this
        notebook, we only need a subset of the available columns, namely delay
        metrics, origin and destination states, and the flight date. We'll
        ignore the other fields.
      </p>
    </div>
  </div>
</div>
<div class="cell border-box-sizing code_cell rendered">
  <div class="input">
    <div class="prompt input_prompt">In&nbsp;[9]:</div>
    <div class="inner_cell">
      <div class="input_area">
        <div class="highlight hl-ipython3">
          <pre><span></span><span class="n">columns</span> <span class="o">=</span> <span class="p">[</span><span class="sa">u</span><span class="s1">&#39;FL_DATE&#39;</span><span class="p">,</span> <span class="sa">u</span><span class="s1">&#39;ORIGIN_STATE_ABR&#39;</span><span class="p">,</span> <span class="sa">u</span><span class="s1">&#39;DEST_STATE_ABR&#39;</span><span class="p">,</span> <span class="sa">u</span><span class="s1">&#39;ARR_DEL15&#39;</span><span class="p">,</span> <span class="sa">u</span><span class="s1">&#39;ARR_DELAY_NEW&#39;</span><span class="p">,</span> <span class="sa">u</span><span class="s1">&#39;DEP_DEL15&#39;</span><span class="p">,</span> <span class="sa">u</span><span class="s1">&#39;DEP_DELAY_NEW&#39;</span><span class="p">,</span> <span class="sa">u</span><span class="s1">&#39;DISTANCE&#39;</span><span class="p">,</span> <span class="sa">u</span><span class="s1">&#39;DISTANCE_GROUP&#39;</span><span class="p">,]</span>
</pre>
        </div>
      </div>
    </div>
  </div>
</div>
<div class="cell border-box-sizing text_cell rendered">
  <div class="prompt input_prompt"></div>
  <div class="inner_cell">
    <div class="text_cell_render border-box-sizing rendered_html">
      <p>
        Moving forward, we'll assume we only have 1 GB of RAM total. Since we're
        only dealing with half a million records here, we can probably pull the
        entire contents of the database into local memory. If the data proves
        too large, we can rely on the map/reduce and search capabilities in
        Cloudant to work with the data instead.
      </p>
      <p>
        Being optimistic, we write a little loop that gets up to 20,000 docs at
        a time from the database. It stores the 20,000 in a simple Python list.
        Once the buffer reaches the threshold, we create a DataFrame from the
        buffer which reduces the data to just the fields we want. We do this
        chunking because appending to a DataFrame one row at a time is much
        slower.
      </p>
    </div>
  </div>
</div>
<div class="cell border-box-sizing code_cell rendered">
  <div class="input">
    <div class="prompt input_prompt">In&nbsp;[10]:</div>
    <div class="inner_cell">
      <div class="input_area">
        <div class="highlight hl-ipython3">
          <pre><span></span><span class="o">%%</span><span class="n">time</span>
<span class="n">dfs</span> <span class="o">=</span> <span class="p">[]</span>
<span class="n">buff</span> <span class="o">=</span> <span class="p">[]</span>
<span class="k">for</span> <span class="n">i</span><span class="p">,</span> <span class="n">item</span> <span class="ow">in</span> <span class="nb">enumerate</span><span class="p">(</span><span class="n">database</span><span class="o">.</span><span class="n">all_docs</span><span class="p">(</span><span class="n">params</span><span class="o">=</span><span class="p">{</span><span class="s1">&#39;include_docs&#39;</span> <span class="p">:</span> <span class="kc">True</span><span class="p">})):</span>
    <span class="n">buff</span><span class="o">.</span><span class="n">append</span><span class="p">(</span><span class="n">item</span><span class="p">[</span><span class="s1">&#39;doc&#39;</span><span class="p">])</span>
    <span class="k">if</span> <span class="n">i</span> <span class="o">&gt;</span> <span class="mi">0</span> <span class="ow">and</span> <span class="n">i</span> <span class="o">%</span> <span class="mi">20000</span> <span class="o">==</span> <span class="mi">0</span><span class="p">:</span>
        <span class="nb">print</span> <span class="s1">&#39;Processed #</span><span class="si">{}</span><span class="s1">&#39;</span><span class="o">.</span><span class="n">format</span><span class="p">(</span><span class="n">i</span><span class="p">)</span>
        <span class="n">df</span> <span class="o">=</span> <span class="n">pandas</span><span class="o">.</span><span class="n">DataFrame</span><span class="p">(</span><span class="n">buff</span><span class="p">,</span> <span class="n">columns</span><span class="o">=</span><span class="n">columns</span><span class="p">)</span>
        <span class="n">dfs</span><span class="o">.</span><span class="n">append</span><span class="p">(</span><span class="n">df</span><span class="p">)</span>
        <span class="n">buff</span> <span class="o">=</span> <span class="p">[]</span>
<span class="c1"># don&#39;t forget the leftovers</span>
<span class="n">df</span> <span class="o">=</span> <span class="n">pandas</span><span class="o">.</span><span class="n">DataFrame</span><span class="p">(</span><span class="n">buff</span><span class="p">,</span> <span class="n">columns</span><span class="o">=</span><span class="n">columns</span><span class="p">)</span>
<span class="n">dfs</span><span class="o">.</span><span class="n">append</span><span class="p">(</span><span class="n">df</span><span class="p">)</span>
</pre>
        </div>
      </div>
    </div>
  </div>

  <div class="output_wrapper">
    <div class="output">
      <div class="output_area">
        <div class="prompt"></div>

        <div class="output_subarea output_stream output_stdout output_text">
          <pre>

Processed #20000
Processed #40000
Processed #60000
Processed #80000
Processed #100000
Processed #120000
Processed #140000
Processed #160000
Processed #180000
Processed #200000
Processed #220000
Processed #240000
Processed #260000
Processed #280000
Processed #300000
Processed #320000
Processed #340000
Processed #360000
Processed #380000
Processed #400000
Processed #420000
Processed #440000
Processed #460000
Processed #480000
Processed #500000
CPU times: user 29 s, sys: 1.92 s, total: 30.9 s
Wall time: 43.5 s

</pre
          >
        </div>
      </div>
    </div>
  </div>
</div>
<div class="cell border-box-sizing text_cell rendered">
  <div class="prompt input_prompt"></div>
  <div class="inner_cell">
    <div class="text_cell_render border-box-sizing rendered_html">
      <p>
        Now we can build one DataFrame by quickly concatenating all the
        subframes we built in the loop above.
      </p>
    </div>
  </div>
</div>
<div class="cell border-box-sizing code_cell rendered">
  <div class="input">
    <div class="prompt input_prompt">In&nbsp;[11]:</div>
    <div class="inner_cell">
      <div class="input_area">
        <div class="highlight hl-ipython3">
          <pre><span></span><span class="n">df</span> <span class="o">=</span> <span class="n">pandas</span><span class="o">.</span><span class="n">concat</span><span class="p">(</span><span class="n">dfs</span><span class="p">)</span>
</pre>
        </div>
      </div>
    </div>
  </div>
</div>
<div class="cell border-box-sizing text_cell rendered">
  <div class="prompt input_prompt"></div>
  <div class="inner_cell">
    <div class="text_cell_render border-box-sizing rendered_html">
      <p>
        At this point, we have two copies of all the data in memory, which is
        undesirable. Before we delete the temporary buffer and subframes to free
        up some RAM, let's ensure the DataFrame row count matches the document
        count in the database.
      </p>
    </div>
  </div>
</div>
<div class="cell border-box-sizing code_cell rendered">
  <div class="input">
    <div class="prompt input_prompt">In&nbsp;[12]:</div>
    <div class="inner_cell">
      <div class="input_area">
        <div class="highlight hl-ipython3">
          <pre><span></span><span class="k">assert</span> <span class="nb">len</span><span class="p">(</span><span class="n">df</span><span class="p">)</span> <span class="o">==</span> <span class="n">database</span><span class="o">.</span><span class="n">get</span><span class="p">()</span><span class="o">.</span><span class="n">json</span><span class="p">()[</span><span class="s1">&#39;doc_count&#39;</span><span class="p">]</span>
</pre>
        </div>
      </div>
    </div>
  </div>
</div>
<div class="cell border-box-sizing code_cell rendered">
  <div class="input">
    <div class="prompt input_prompt">In&nbsp;[13]:</div>
    <div class="inner_cell">
      <div class="input_area">
        <div class="highlight hl-ipython3">
          <pre><span></span><span class="k">del</span> <span class="n">dfs</span>
<span class="k">del</span> <span class="n">buff</span>
</pre>
        </div>
      </div>
    </div>
  </div>
</div>
<div class="cell border-box-sizing code_cell rendered">
  <div class="input">
    <div class="prompt input_prompt">In&nbsp;[14]:</div>
    <div class="inner_cell">
      <div class="input_area">
        <div class="highlight hl-ipython3">
          <pre><span></span><span class="err">!</span><span class="n">free</span> <span class="o">-</span><span class="n">m</span>
</pre>
        </div>
      </div>
    </div>
  </div>

  <div class="output_wrapper">
    <div class="output">
      <div class="output_area">
        <div class="prompt"></div>

        <div class="output_subarea output_stream output_stdout output_text">
          <pre>
             total       used       free     shared    buffers     cached

Mem: 989 700 289 1 73 178
-/+ buffers/cache: 449 540
Swap: 2047 29 2017

</pre
          >
        </div>
      </div>
    </div>
  </div>
</div>
<div class="cell border-box-sizing text_cell rendered">
  <div class="prompt input_prompt"></div>
  <div class="inner_cell">
    <div class="text_cell_render border-box-sizing rendered_html">
      <p>
        As one last step, we reset the index on the DataFrame so that it is a
        unique, monotonically increasing integer. As it stands, we have dupes in
        our index because of our chunking (i.e., each chunk starts at index 0).
        This reset will prove important in some of our later plots where the
        index must be unique per row.
      </p>
    </div>
  </div>
</div>
<div class="cell border-box-sizing code_cell rendered">
  <div class="input">
    <div class="prompt input_prompt">In&nbsp;[15]:</div>
    <div class="inner_cell">
      <div class="input_area">
        <div class="highlight hl-ipython3">
          <pre><span></span><span class="n">df</span> <span class="o">=</span> <span class="n">df</span><span class="o">.</span><span class="n">reset_index</span><span class="p">(</span><span class="n">drop</span><span class="o">=</span><span class="kc">True</span><span class="p">)</span>
</pre>
        </div>
      </div>
    </div>
  </div>
</div>
<div class="cell border-box-sizing text_cell rendered">
  <div class="prompt input_prompt"></div>
  <div class="inner_cell">
    <div class="text_cell_render border-box-sizing rendered_html">
      <h2 id="Distribution-of-Delay-Counts-by-State">
        Distribution of Delay Counts by State<a
          class="anchor-link"
          href="#Distribution-of-Delay-Counts-by-State"
          >&#182;</a
        >
      </h2>
      <blockquote>
        <p>
          What is the distribution of departure delays of at least 15 minutes by
          state? Arrival delays?
        </p>
      </blockquote>
      <p>
        Let's look at some basic information about delays to start and work up
        to delays grouped by state. Because the question asks about delays 15
        minutes or longer, we'll focus on the <code>DEP_DEL15</code> and
        <code>ARR_DEL15</code> columns.
      </p>
    </div>
  </div>
</div>
<div class="cell border-box-sizing code_cell rendered">
  <div class="input">
    <div class="prompt input_prompt">In&nbsp;[16]:</div>
    <div class="inner_cell">
      <div class="input_area">
        <div class="highlight hl-ipython3">
          <pre><span></span><span class="n">df</span><span class="o">.</span><span class="n">DEP_DEL15</span><span class="o">.</span><span class="n">value_counts</span><span class="p">()</span> <span class="o">/</span> <span class="nb">len</span><span class="p">(</span><span class="n">df</span><span class="p">)</span>
</pre>
        </div>
      </div>
    </div>
  </div>

  <div class="output_wrapper">
    <div class="output">
      <div class="output_area">
        <div class="prompt output_prompt">Out[16]:</div>

        <div class="output_text output_subarea output_execute_result">
          <pre>

0 0.731817
1 0.248993
dtype: float64</pre
          >

</div>
</div>
</div>

  </div>
</div>
<div class="cell border-box-sizing code_cell rendered">
  <div class="input">
    <div class="prompt input_prompt">In&nbsp;[17]:</div>
    <div class="inner_cell">
      <div class="input_area">
        <div class="highlight hl-ipython3">
          <pre><span></span><span class="n">df</span><span class="o">.</span><span class="n">ARR_DEL15</span><span class="o">.</span><span class="n">value_counts</span><span class="p">()</span> <span class="o">/</span> <span class="nb">len</span><span class="p">(</span><span class="n">df</span><span class="p">)</span>
</pre>
        </div>
      </div>
    </div>
  </div>

  <div class="output_wrapper">
    <div class="output">
      <div class="output_area">
        <div class="prompt output_prompt">Out[17]:</div>

        <div class="output_text output_subarea output_execute_result">
          <pre>

0 0.718265
1 0.258054
dtype: float64</pre
          >

</div>
</div>
</div>

  </div>
</div>
<div class="cell border-box-sizing text_cell rendered">
  <div class="prompt input_prompt"></div>
  <div class="inner_cell">
    <div class="text_cell_render border-box-sizing rendered_html">
      <p>
        Roughly a quarter of all departures and a quarter of all arrivals have
        delays. We can look at the distribution more closely once we enable and
        configure plotting with
        <a href="http://matplotlib.org/">matplotlib</a> and
        <a href="http://web.stanford.edu/~mwaskom/software/seaborn/">seaborn</a
        >.
      </p>
    </div>
  </div>
</div>
<div class="cell border-box-sizing code_cell rendered">
  <div class="input">
    <div class="prompt input_prompt">In&nbsp;[18]:</div>
    <div class="inner_cell">
      <div class="input_area">
        <div class="highlight hl-ipython3">
          <pre><span></span><span class="o">%</span><span class="n">matplotlib</span> <span class="n">inline</span>
</pre>
        </div>
      </div>
    </div>
  </div>
</div>
<div class="cell border-box-sizing code_cell rendered">
  <div class="input">
    <div class="prompt input_prompt">In&nbsp;[19]:</div>
    <div class="inner_cell">
      <div class="input_area">
        <div class="highlight hl-ipython3">
          <pre><span></span><span class="kn">import</span> <span class="nn">matplotlib.pyplot</span> <span class="k">as</span> <span class="nn">plt</span>
</pre>
        </div>
      </div>
    </div>
  </div>
</div>
<div class="cell border-box-sizing code_cell rendered">
  <div class="input">
    <div class="prompt input_prompt">In&nbsp;[20]:</div>
    <div class="inner_cell">
      <div class="input_area">
        <div class="highlight hl-ipython3">
          <pre><span></span><span class="kn">import</span> <span class="nn">seaborn</span> <span class="k">as</span> <span class="nn">sns</span>
<span class="n">sns</span><span class="o">.</span><span class="n">set_palette</span><span class="p">(</span><span class="s2">&quot;deep&quot;</span><span class="p">,</span> <span class="n">desat</span><span class="o">=.</span><span class="mi">6</span><span class="p">)</span>
<span class="n">colors</span> <span class="o">=</span> <span class="n">sns</span><span class="o">.</span><span class="n">color_palette</span><span class="p">(</span><span class="s2">&quot;deep&quot;</span><span class="p">)</span>
<span class="n">sns</span><span class="o">.</span><span class="n">set_context</span><span class="p">(</span><span class="n">rc</span><span class="o">=</span><span class="p">{</span><span class="s2">&quot;figure.figsize&quot;</span><span class="p">:</span> <span class="p">(</span><span class="mi">18</span><span class="p">,</span> <span class="mi">5</span><span class="p">)})</span>
</pre>
        </div>
      </div>
    </div>
  </div>
</div>
<div class="cell border-box-sizing text_cell rendered">
  <div class="prompt input_prompt"></div>
  <div class="inner_cell">
    <div class="text_cell_render border-box-sizing rendered_html">
      <p>
        Let's group by state now and sum the number of delays. We'll do it for
        both departure and arrival delays.
      </p>
    </div>
  </div>
</div>
<div class="cell border-box-sizing code_cell rendered">
  <div class="input">
    <div class="prompt input_prompt">In&nbsp;[21]:</div>
    <div class="inner_cell">
      <div class="input_area">
        <div class="highlight hl-ipython3">
          <pre><span></span><span class="n">by_origin_state</span> <span class="o">=</span> <span class="n">df</span><span class="o">.</span><span class="n">groupby</span><span class="p">(</span><span class="s1">&#39;ORIGIN_STATE_ABR&#39;</span><span class="p">)</span>
<span class="n">departure_delay_counts</span> <span class="o">=</span> <span class="n">by_origin_state</span><span class="o">.</span><span class="n">DEP_DEL15</span><span class="o">.</span><span class="n">sum</span><span class="p">()</span>
</pre>
        </div>
      </div>
    </div>
  </div>
</div>
<div class="cell border-box-sizing code_cell rendered">
  <div class="input">
    <div class="prompt input_prompt">In&nbsp;[22]:</div>
    <div class="inner_cell">
      <div class="input_area">
        <div class="highlight hl-ipython3">
          <pre><span></span><span class="n">by_dest_state</span> <span class="o">=</span> <span class="n">df</span><span class="o">.</span><span class="n">groupby</span><span class="p">(</span><span class="s1">&#39;DEST_STATE_ABR&#39;</span><span class="p">)</span>
<span class="n">arrival_delay_counts</span> <span class="o">=</span> <span class="n">by_dest_state</span><span class="o">.</span><span class="n">ARR_DEL15</span><span class="o">.</span><span class="n">sum</span><span class="p">()</span>
</pre>
        </div>
      </div>
    </div>
  </div>
</div>
<div class="cell border-box-sizing text_cell rendered">
  <div class="prompt input_prompt"></div>
  <div class="inner_cell">
    <div class="text_cell_render border-box-sizing rendered_html">
      <p>
        To plot, we'll put both series in a DataFrame so we can view the arrival
        and departure delays for each state side-by-side.
      </p>
    </div>
  </div>
</div>
<div class="cell border-box-sizing code_cell rendered">
  <div class="input">
    <div class="prompt input_prompt">In&nbsp;[23]:</div>
    <div class="inner_cell">
      <div class="input_area">
        <div class="highlight hl-ipython3">
          <pre><span></span><span class="n">delay_df</span> <span class="o">=</span> <span class="n">pandas</span><span class="o">.</span><span class="n">DataFrame</span><span class="p">([</span><span class="n">departure_delay_counts</span><span class="p">,</span> <span class="n">arrival_delay_counts</span><span class="p">])</span><span class="o">.</span><span class="n">T</span>
</pre>
        </div>
      </div>
    </div>
  </div>
</div>
<div class="cell border-box-sizing code_cell rendered">
  <div class="input">
    <div class="prompt input_prompt">In&nbsp;[24]:</div>
    <div class="inner_cell">
      <div class="input_area">
        <div class="highlight hl-ipython3">
          <pre><span></span><span class="n">delay_df</span><span class="o">.</span><span class="n">sort</span><span class="p">(</span><span class="s1">&#39;DEP_DEL15&#39;</span><span class="p">,</span> <span class="n">ascending</span><span class="o">=</span><span class="kc">False</span><span class="p">)</span><span class="o">.</span><span class="n">plot</span><span class="p">(</span><span class="n">kind</span><span class="o">=</span><span class="s1">&#39;bar&#39;</span><span class="p">,</span> <span class="n">title</span><span class="o">=</span><span class="s1">&#39;Number of delayed flights by state&#39;</span><span class="p">)</span>
</pre>
        </div>
      </div>
    </div>
  </div>

  <div class="output_wrapper">
    <div class="output">
      <div class="output_area">
        <div class="prompt output_prompt">Out[24]:</div>

        <div class="output_text output_subarea output_execute_result">
          <pre>

&lt;matplotlib.axes.\_subplots.AxesSubplot at 0x7f67ac978990&gt;</pre
          >

</div>
</div>

      <div class="output_area">
        <div class="prompt"></div>

        <div class="output_png output_subarea">
          <img
            src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAABCAAAAFbCAYAAAAEMf/AAAAABHNCSVQICAgIfAhkiAAAAAlwSFlz

AAALEgAACxIB0t1+/AAAIABJREFUeJzs3WmYHGXZt/FzQgiICZOEREIgBInxQgVkUcFHWVRUUBQF
ZFNEQEVRRNwRREXADdlEEBdkUXgEQVxAFvFFQB9FWURFL1BDGAJEIAkkoEwS5v1QNUOnp2fpme5M
Z3L+jiNHemq56u6e7p6qf911V1tXVxeSJEmSJEnNNGakGyBJkiRJkkY/AwhJkiRJktR0BhCSJEmS
JKnpDCAkSZIkSVLTGUBIkiRJkqSmM4CQJEmSJElNZwAhSVKDRcR5EfGFEdz+9yJiQUT8bhDLbhIR
T0fEgPsEEfGuiLipMa0cvIi4ISIO7Wd+z/ONiJ0ioqNi3l8iYsdBbufeiHhNI9pcVXfnyjZJkrS6
MoCQJI165YHl/IhYp2LauyPi/zVpk13lv5UuInYAdgGmZ+b2I9GGJujz9azxfNsq52fm5pl5YwO2
09IhwlDaVwZPmzarTZIkVTOAkCStLsYAR67E7bUNvMjABtMzocpM4N7M/G8jtr8KWN2eb6M15H0q
SdJgjB3pBkiStBJ0AScDn4iIszLzscqZEbEJ8C9gbGY+XU67AbgwM78bEe8C3gP8HjgYeBR4JxDA
54G1gI9n5gUVZadExLXA9sBtwDsz876y9mbA14FtgIeBz2TmpeW884D/UBxY7wi8GfhVVXunA98E
XgEsAL6cmd8pL1M4E1gzIhYDJ2fm56vWHQN8BTgIeBw4pWp+ezltN+Bp4HvAZ7tfl6plTwfeCrQD
9wAfzsybI2Ia8E9gRmYuKJfdBrga2CAzl0fEIcDHgGnALcB7K16f15avzzTgQoqD5F4HyrWeL3BD
1TL3Aodm5vUR8azydXsT8BBwHnBEZs6oWGXriDiV4vW/unydxgK/AMaV2+kCng9sDJwFzKb4nf0g
Mz9a3c6KthwNfARYAhyTmRdFxEuBn5WvS1e53J7AcZm5VY0abwC+Cszgmd/fN/tp3+nAZmX7LgM+
kplLI6K7V8ifIqILOCQzL42I3YETyud/F/C+zPxzX89JkqR62ANCkrS6+CPFwenHBrl8dXf8lwF/
AiYDFwOXUAQIs4B3AGdWXOLRBrwdOB6YAtwB/AAgIp4NXAd8H5gK7AecFREvqNjW/sAXMnM88Jsa
bftf4D5gA2Bv4KSIeFVmfhd4H/B/mTmhOnwovRd4I7AV8JJy/crneR7QWT6vrYHXAe/u4zW6BXgx
MAm4CLg0IsZl5kMUr/U+FcseCFxchg97AEdThBdTgJsoXlMiYgrFgfKngfUogoxXUOPSiD6eb3VQ
Ufl7/CzFQflzgddS/N4q67YBbwNeXy6zJfCuzHwC2BV4oNzOuuVzPB04NTPbgU0p3hN9mVY+n+kU
oca3ImJ2Zv6BItB6fdVrdX4fdb5LEdasC7wI+H+Z+WQf7VtG0etnPeDlwGuAw8vXrntcjC3LdS6N
iK3L+u+heJ+fA/w0Isb187wkSRo0AwhJ0uqiCzgOOKI8yK3XnMw8vzxLfQnFgeTxmbk0M6+jOGh/
XsXyP8/MmzOzEzgGeHlEbATsXlHr6cy8A7ic4sC32xWZ+X8AmflUZSMiYgbwP8AnM7MzM/8EfIei
RwYM3KV+H4qD5nmZuRA4qXudiFifoufDUZn5n8x8GDiNIiTpJTN/kJkLy+dxCkVPkChnX0BxgE9E
rFHWuLCc9z7gi1l4GvgisFVEbAy8AfhLZl6emcsz8zSK3gp9qecSgrcBJ2XmY5k5jyJAqFy/Czgj
Mx8qX5ufUQQ1fW2nE5gdEVMy88nM/P0A2/9M+X65EbgS2LecXvlaTaYIfS7qo0Yn8KKIWLd8Hrf3
1b7MvC0zbyl/P3OBbwE79dO+9wLnZOYfMrOr7NHzFEUvHkmShs1LMCRJq43M/GtE/Bz4FPC3Olef
X/H4P2W9h6umjS8fdwH3V2z3iYhYQBFazAS2i4iFFeuOpTgI7bVuDdOBBeVZ+W73UfRmGIwNgMrB
Cu+reDwTWBN4MKI7R2BM1TI9IuJjwCFlm7qAdSl6NAD8BDi7vLxlM+CxzPxjxXZOj4ivVZXcsGxf
9fNv1OCP06tq1XqdK8OO/5Tr9OVQil4uf4uIOcDnM/PKPpZdmJn/qfh5bkXtHwB/LXvQ7APcmJnz
qwuU9gKOBb4UEXcCn8rMmnc7iYjnU1yisS2wDsX77I+1li3NBN4ZEUdUTFuT4nciSdKwGUBIklY3
n6UYk6Hy4Lf7YH4diuvzoegyP1RtFNfoAxAR4ym6tM+jOJj/dWa+boi1HwAmR8T4zOxu68b0H1pU
erBcvlvl4w6KM97r1RrzoVJ594mPA6/OzL+W0xZQnonPzP9GxKUUZ/Y345mABYrX4AuZeXGNurNZ
8bVb4bUcpgfLWn8vf66nbq1LQP4BHAAQEXsBP4qIyVVBQ7dJEbFOebkEFAf7d5Z17i9vmbonxet1
Vl+NKEOct5S9So6g6I2zca32AWcDtwL7liHYhykCjL7cB5yYmSf1s4wkSUPmJRiSpNVKZv4T+CEV
d8QoezLMAw6MiDXKARJnDXNTb4iIV5TXz3+BYpyCeRRd758fEe+IiDXLfy8tB6aEAS4pyMwO4LfA
FyNirYjYkqIXwvcH2a5LgA9FxIYRMYmiN0h37QeBa4FTImJCRIyJiFkRsWONOhMoxhh4JCLGRcRx
FD0gKl1AMWjnm3nm8gsoBk38dES8EIqBLyOi+xKUqyguMXhrRIwFPsTwwqBKlwBHR8TEiNgQ+CCD
v13qfGC9iOh5juXvcGr542Nlrf6Cm8+Xv+8dKMbhuLRi3gXAJ4HNKS7J6aVc9+0R0Z6Zy4HFwPK+
2kfRI2cx8GT5/np/jedU+T7/NvC+iHhZRLRFxLMj4o1lgCZJ0rAZQEiSVkfHU/R2qDz4fA/FGf1H
gBey4uCP1QNSUuPn6nk/oOht8SjFYI7vAMjMxRTX+O9HEXo8SDEGwriKdQc6KN4f2ISiN8TlFHdM
6L5TxkDrfxu4hmJAzT9SDPhYufw7y7bcRXGHjUt5JgCorH11+e9u4F6KyxVWuFQjM39DcUB+axmc
dE+/Avgy8L8R8RjwZ8pBGDPzEYqxGr5E8bt4HnBzP8+nnt/N8RQ9ReZQBC2XUoypMGDtzPw7xUCZ
/4qIBRGxQdnmv5R3njgV2K96zI6KOg8CCyl+ZxcCh2Xm3RXLXE7Rk+HH2f8tRd8BzClft/dSDHZa
q33TKAZcPYDibhnfohi8tPK1+RxwfkQsjIi9M/NWis/BmRS/+3t4ZmwRSZKGra2rq+99lHKgqwuA
51D8wfpWZp5RDpD0Q8p7bwP7ZOaicp2jKc7ELAc+lJnXltO3pRhZe23gqsw8spy+VrmNbSh20vYt
B0qSJEmruIj4JXBRZp470m2pFhHvp9iHedVItwUgIu6hCCZ+NeDCkiStggbqAbGUYiTsF1GMgPyB
8jZhnwKuy8znA9eXP1N2pdyX4szRrhS3FevuSno2xX24Z1OMGL1rOf1Q4NFy+qkUZ0QkSdIqLiJe
SnGC4Ycj3RaAiJhWXhYzJopRNj8C/Hik2wUQEXsCXYYPkqTRrN8AorwN1R3l4yUUI4ZvSHEtZ/f9
qc8H3lI+3oPiHt9LM/Ne4B8UI31vAEzIzFvK5S6oWKey1mUU96iWJEmrsIg4H7gO+HDVHTtG0jiK
8ScepziBcgX9DPi4skTEDWU7PjDCTZEkqakGfReM8jZaWwO/B9avuD3UfGD98vF0oPJWUPdTBBZL
WXF07nnldMr/OwAyc1lEPFaOIL2gvqciSZJaRWYeNNJtqJaZ9wFbjHQ7qmXmziPdBkmSVoZBDUJZ
jn58GXBkOXhWj8wczGBZkiRJkiRpNTZgD4iIWJMifLiwHLUaYH5ETMvMh8rLK/5dTp/HivfU3oii
58O88nH19O51NgYeKG+31T5Q74dly5Z3jR27xkBNlyRJkiRJK1eftxTvN4AoB5D8LnBXZp5WMeun
wEEUA0YeRHENZff0iyLiFIpLK2YDt2RmV0Q8HhHbAbcABwJnVNX6HbA3xTWZ/Vq48MmBFmHq1Ak8
/PDiAZcbDGtZy1ojX8da1rKWtazVurVasU3Wspa1rGWtxtYabJ2pUyf0OW+gHhCvoLjf9J0RcXs5
7WiKe3NfEhGHUt6GEyAz74qISyjuHb4MOLy8RAPgcIrbcD6L4jacV5fTvwtcWN566lGK+6JLkiRJ
kqRRpN8AIjNvpu9xInbpY52TgJNqTL+VGgM/ZeZTlAGGJEmSJEkanQY1CKUkSZIkSdJwGEBIkiRJ
kqSmM4CQJEmSJElNZwAhSZIkSZKazgBCkiRJkiQ13UC34ZQkSZIkaZXS2dlJR8fcAZdbuHA8CxYs
GVTNGTNmMm7cuOE2bbVmACFJkiRJGlU6OuZy3CkXMn7ilIbUW7LoEY7/yIHMmjW7z2Ve8IIXMGvW
81i2bBlrrDGWXXd9A/vu+3ba2tq47bY/cvTRH2X69A17lv/gB49i221fyo47voxZs57H8uXLmTnz
uRx77OeACTW30b1sPdvYdddX89rX7sB11920Qq077riNM874Gv/85z/4/OdPYuedX9NrOwDTpm3A
F7/4tSG8ar0ZQEiSJEmSRp3xE6fQPnnaStve2muvzfe+dxEACxcu5POfP4YnnniCQw89DICtttqG
L3/51F7rrbXWM+sdf/xnuOKKy/jgB99XcxuVy9azDWjrNWXatA045pjPc/HFF/a7nUZa5ceA6Ozs
5J//vKfXv87OzpFumiRJkiRpNTRp0iQ+8YljuPzyS3qmdXUNvN6WW76Y+++/v6nb6DZt2gbMmvU8
xoxZebHAKt8DolbXmiWLHuHME97PpEkbjGDLJEmSJEmrq+nTN2T58qdZuHAhAHfeeTsHH3xAz/wT
T/zqCpdLLFu2jN/97rdsv/0rGrqNqVM3q7vtnZ1Pccgh72DNNdfkHe84iB122LnuGrWs8gEErPyu
NZIkSZIk1WPLLbfmK1/pfXlEZ+dTPaHBi1+8DbvvvkfDt1Gvyy67kilTpvDAA/M48sj3s+mmz2Pq
1BcMu+6oCCAkSZIkSWol8+bdzxprjGHSpEnMmdP3cuPGrTXk8RYGu42BtLWtOEbElCnFFQbTp2/I
1ltvyz33JFttZQAhSZIkSVIvSxY9MmK1Fi5cyMknf5G99tq3YW1o1ja6urroqhg8YvHixay11lqM
GzeORYsWceedf+Ltbz9ouM0FDCAkSZIkSaPMjBkzOf4jBw643OTJ41mwYMmga/bnqaeKSykqb5G5
337vAIoeBtXjM7zrXe9mp51e3av3QX+6L9eoZxt7770HTz31X/bc84090/fb7+1sueVWfPrTH2fx
4sf57W9v4txzv8UFF/yQe+/9Fyef/EXa2sbQ1fU0Bx74LmbO3GTQbeyPAYQkSZIkaVQZN24cs2bN
HnC5qVMn8PDDixuyzbvuuqvPWltvvS1XX31DzXnXXvvrQW/j17/+fZ/z+tvGjTfeUnP65Zdf2Wva
Flu8mPPP/99Bt6keq/xtOCVJkiRJUuuzB4QkSZIkSS3isccW8Z73HMiyZctXmH766Wez7rrtI9Sq
xjCAkCRJkiSpRbS3T+SKK65o2KUhrcRLMCRJkiRJUtMZQEiSJEmSpKbzEgxJkiRJ0qjS2dlJR8fc
AZdbuLC+23COGzduuE1brRlASJIkSZJGlY6OuRx/0QlMWK8xgzYufvQxjjvg2EHd2lN9M4CQJEmS
JI06E9ZrZ+L6k1b6dm+88QaOOebj/OAHl7Lxxpvw4IMP8Pa3v42ZM2eybNkyXvSiLfjEJ45hzJgx
3HbbHzn66I8yffqGLF26lB13fBXvfe/hfda+6qqfcdZZp/Oc56zPk0/+h+nTN+SQQ97D5ptvCcCJ
J36OO+64nfHjnw3A2ms/ix/96BKuuupnZP6No476xAr1zjnnG1xzzVUsXryY6667sdd2pk59DgB7
7bUvBx/8jmG/NgYQkiRJkiQ1yC9/eQ3/8z+v5LrrruHQQw8DYKONNuJ737uIp59+mqOO+gA33vj/
2Hnn1wDw4hdvw1e+cipPPfUUhxzydnbc8VVMnfqymrXb2trYZZfX8+EPfxyA2277I8cc83HOOOMc
Zs7chLa2Nj74wSPZaadX91qvlh122Im9996X/fbbs9/tNIqDUEqSJEmS1ABPPvkkd931F4466pP8
6lfX9Zo/ZswYXvCCFzFv3v295q211lo873nP54EH5vW7ja6urp7H22zzEt785j356U8vrzl/IC98
4east96Umtuop85gjcoeEE8vX8acOXN6DSbioCGSJEmSpGa5+eZfs912L2fatGlMnDiJzL+z7rrr
9sx/6qmnuOOO2zjooEN6rfv444/xt7/9lYMOOrSubc6eHT0BRFdXF9/4xhmcf/53Adh001mcccZp
dYcJbW1t3HDDr7jjjtuYMWMmH/rQR5g6dUJdNWoZlQHEE4sXcfqV56ww4IiDhkiSJEmSmumXv7yG
ffY5AIBXveo1/PKX17DXXvswb979HHzwATz44ANsu+1LefnLX9mzzp133s673nUA999/H3vssReb
bjqrrm1Whgv1XoLRl1e8Ygde+9pdGTt2LD/5yeWceOLnuOii79dVo5ZRGUBA4wYc6ezs5O6777Y3
hSRJkiStQhY/+thKrbVo0SJuu+2P/Otf/6StrY3ly5czZswY9tzzbWy4YTEGxGOPLeIDH3gvf//7
XWy22QsB2HLLrfnKV07lwQcf4EMfeh/77LN/Xb0N7rkn2WSTTYf83GpZd91nTubvvvsenH32GQ2p
O2oDiEapdfsWe1NIkiRJUuuaMWMmxx1w7IDLTZ48vtfJ5v5q9ueaa65h113fyMc+dnTPtA9+8L3M
n/9Qz8/t7RN573sP55xzvsGpp35jhfU32GA6b3vbfpx33nc5+eQv1dxG9aUUt99+Kz/72Y/5+tfP
6XOZvqb159FHH+kZG+Lmm29sWMBhADEII3X7FkmSJElS/caNGzeoE8ZTp07g4YcXN2SbV155Jfvu
e+AK03be+dV8//vnrXAJxI477sy5536Lu+76C21tbVReHbHHHnux//578tBDD7HGGs/utY22tjau
v/467rzzDv773/8yffpGnHjiV9l44016lqkcA6KtrY3LL7+MtrY2rrrq59x00697ljvnnO9x6aUX
88tfXktn51PsuecbedOb3sLBB7+HH/3oh9x8869ZY42xtLe38+lPf7Yhr5EBhCRJkiRJw3TBBRf0
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
AElFTkSuQmCC
"
/>

</div>
</div>
</div>

  </div>
</div>
<div class="cell border-box-sizing text_cell rendered">
  <div class="prompt input_prompt"></div>
  <div class="inner_cell">
    <div class="text_cell_render border-box-sizing rendered_html">
      <p>
        Big states with big airports appear to be in the top five. But we
        haven't accounted for how many total flights these states service. We
        should plot the percentage of flights that are delayed.
      </p>
    </div>
  </div>
</div>
<div class="cell border-box-sizing code_cell rendered">
  <div class="input">
    <div class="prompt input_prompt">In&nbsp;[25]:</div>
    <div class="inner_cell">
      <div class="input_area">
        <div class="highlight hl-ipython3">
          <pre><span></span><span class="n">pct_departure_delay</span> <span class="o">=</span> <span class="n">departure_delay_counts</span> <span class="o">/</span> <span class="n">df</span><span class="o">.</span><span class="n">ORIGIN_STATE_ABR</span><span class="o">.</span><span class="n">value_counts</span><span class="p">()</span>
<span class="n">pct_arrival_delay</span> <span class="o">=</span> <span class="n">arrival_delay_counts</span> <span class="o">/</span> <span class="n">df</span><span class="o">.</span><span class="n">DEST_STATE_ABR</span><span class="o">.</span><span class="n">value_counts</span><span class="p">()</span>
</pre>
        </div>
      </div>
    </div>
  </div>
</div>
<div class="cell border-box-sizing text_cell rendered">
  <div class="prompt input_prompt"></div>
  <div class="inner_cell">
    <div class="text_cell_render border-box-sizing rendered_html">
      <p>
        Ranking states of origin by their percentage of departures tells a
        different story than the plot above. For example, here we see Illinois
        and Arkansas at the top of the list whereas IL was third in total
        departure delay counts and AR was ranked 25th or so. California, which
        is #2 in the number of total departure delays is only #17 in percentage
        of departures delayed. Not bad.
      </p>
    </div>
  </div>
</div>
<div class="cell border-box-sizing code_cell rendered">
  <div class="input">
    <div class="prompt input_prompt">In&nbsp;[26]:</div>
    <div class="inner_cell">
      <div class="input_area">
        <div class="highlight hl-ipython3">
          <pre><span></span><span class="n">pct_departure_delay</span><span class="o">.</span><span class="n">order</span><span class="p">(</span><span class="n">ascending</span><span class="o">=</span><span class="kc">False</span><span class="p">)</span><span class="o">.</span><span class="n">plot</span><span class="p">(</span><span class="n">kind</span><span class="o">=</span><span class="s1">&#39;bar&#39;</span><span class="p">,</span> <span class="n">title</span><span class="o">=</span><span class="s1">&#39;</span><span class="si">% f</span><span class="s1">lights with departure delays by origin state&#39;</span><span class="p">)</span>
</pre>
        </div>
      </div>
    </div>
  </div>

  <div class="output_wrapper">
    <div class="output">
      <div class="output_area">
        <div class="prompt output_prompt">Out[26]:</div>

        <div class="output_text output_subarea output_execute_result">
          <pre>

&lt;matplotlib.axes.\_subplots.AxesSubplot at 0x7f67abb67e90&gt;</pre
          >

</div>
</div>

      <div class="output_area">
        <div class="prompt"></div>

        <div class="output_png output_subarea">
          <img
            src="data:image/png;base64,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
FiRJkiRJUmMmFiRJkiRJUmMmFiRJkiRJUmMmFiRJkiRJUmMmFiRJkiRJUmMmFiRJkiRJUmMmFiRJ
kiRJUmMmFiRJkiRJUmMmFiRJkiRJUmMmFiRJkiRJUmMmFiRJkiRJUmMmFiRJkiRJUmMmFiRJkiRJ
UmNz+hWIiEOB04DZwJmZeXLb/MOAk4Cbqn8vzcyvV/NWAdcCNwIbM3P/YVZekiRJkiRtXz0TCxEx
GzgdeDiwBrg4Is7LzJUtxS7MzC9U5e8FnAvcuZq3CTg4M9cNveaSJEmSJGm769diYX/gssxcBRAR
5wCHAZsTC5n5p5byY8DVbTFmNa3chg0bGB9fvdX0iYkx1q1bv/n94sX7Mnfu3KarkSRJkiRJDfVL
LOwFjLe8/x1wQHuhiDgceCtwe+CQllmbgAsj4kZgRWaeUady4+OrOfHUsxibv7BrmfXXXM1JJxzN
0qXL6oSWJEmSJElDMGvTpk1dZ0bEEcChmfns6v1TgAMy8/gu5Q+ijMMQ1fvbZ+aVEbEI+CpwfGZe
1G19N9xw46Y5c2Zvfv/LX/6SV5zyGXZfsGfXOv5x3VW87SVP4C53uUuvzylJkiRJkqamY4+Efi0W
1gCLW94vprRa6CgzL4qIORFxm8z8Q2ZeWU1fGxHnUrpWdE0sTExcv8X71u4Ovaxbt561a68bqGy7
RYvmNV52FGLNxDoZy1jGMpaxhhtrJtbJWMYylrGMNXNjzcQ6GWs0Yi1aNK/j9H6Pm7wEWBYRSyJi
LnAkcF5rgYhYGhGzqtf3BcjMP0TEbhExr5p+K0oXiZ/2rakkSZIkSRoZPVssZOYNEXEccAHlcZMf
ysyVEXFsNX8FcATw1IjYCKwHjqoW3xP4XERMrucTmfmV6fkYkiRJkiRpe+jXFYLMPB84v23aipbX
bwfe3mG5y4H7DKGOkiRJkiRphurXFUKSJEmSJKkrEwuSJEmSJKkxEwuSJEmSJKkxEwuSJEmSJKkx
EwuSJEmSJKkxEwuSJEmSJKkxEwuSJEmSJKkxEwuSJEmSJKkxEwuSJEmSJKkxEwuSJEmSJKkxEwuS
JEmSJKkxEwuSJEmSJKkxEwuSJEmSJKkxEwuSJEmSJKkxEwuSJEmSJKkxEwuSJEmSJKkxEwuSJEmS
JKkxEwuSJEmSJKkxEwuSJEmSJKkxEwuSJEmSJKkxEwuSJEmSJKmxOdu7AtvKhg0bGB9fvdX0iYkx
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
pMZMLEiSJEmSpMZMLEiSJEmSpMZMLEiSJEmSpMZMLEiSJEmSpMZMLEiSJEmSpMZMLEiSJEmSpMbm
bO8KSJLBpMRWAAAgAElEQVQkSZK0I9mwYQPj46u3mj4xMca6deu3mLZ48b7MnTt3W1VtWvRNLETE
ocBpwGzgzMw8uW3+XYGPAPsBr87Mdw66rCRJkiRJO5rx8dWceOpZjM1f2LPc+muu5qQTjmbp0mXb
qGbTo2diISJmA6cDDwfWABdHxHmZubKl2B+A44HDGywrSZIkSdIOZ2z+QnZfsOf2rsY20W+Mhf2B
yzJzVWZuBM4BDmstkJlrM/MSYGPdZSVJkiRJ0mjrl1jYCxhvef+7atogprKsJEmSJEkaAf0SC5um
EHsqy0qSJEmSpBHQb/DGNcDilveLKS0PBlF72T322I05c2Zvfj8xMTbQihYsGGPRonk9yxjLWNMV
a9A4xjLWzhhrVPdrYxlrOmON+n5tLGNNZ6xR3a+NZaymcQatVzdNlxt2rH6JhUuAZRGxBLgCOBJY
3qXsrCksC8DExPVbvG9/DEc369atZ+3a6/qWMZaxpiPWoHGMZaydMdao7tfGMtZ0xhr1/dpYxprO
WKO6XxvLWE3jDFqvThYtmtdouanE6pZ86JlYyMwbIuI44ALKIyM/lJkrI+LYav6KiNgTuBi4NXBT
RLwQuHtmru+07OAfTZIkSZKknduGDRsYH1+91fSJibGtEhiLF+/L3Llzt1XVNuvXYoHMPB84v23a
ipbXV7Fll4eey0qSJEmSpMGMj6/mxFPPYmz+wp7l1l9zNSedcDRLly7bRjW7Wd/EgiRJkiRJ2n7G
5i9k9wV7bu9qdNXvqRCSJEmSJEldmViQJEmSJEmNmViQJEmSJEmNmViQJEmSJEmNmViQJEmSJEmN
mViQJEmSJEmNmViQJEmSJEmNmViQJEmSJEmNmViQJEmSJEmNmViQJEmSJEmNmViQJEmSJEmNmViQ
JEmSJEmNmViQJEmSJEmNmViQJEmSJEmNmViQJEmSJEmNmViQJEmSJEmNmViQJEmSJEmNmViQJEmS
JEmNmViQJEmSJEmNmViQJEmSJEmNmViQJEmSJEmNmViQJEmSJEmNzdneFZAkSZIkSdNvw4YNjI+v
3mr6xMQY69at32La4sX7Mnfu3IHimliQJEmSJGknMD6+mhNPPYux+Qt7llt/zdWcdMLRLF26bKC4
JhYkSZIkSdpJjM1fyO4L9hxqzL6JhYg4FDgNmA2cmZkndyjzHuBRwPXA0zPzh9X0VcC1wI3Axszc
f2g1lyRJkiRJ213PwRsjYjZwOnAocHdgeUTcra3MPwB3zsxlwHOA97fM3gQcnJn7mVSQJEmSJGnH
0++pEPsDl2XmqszcCJwDHNZW5p+AjwFk5veB+RFxu5b5s4ZVWUmSJEmSNLP0SyzsBYy3vP9dNW3Q
MpuACyPikoh49lQqKkmSJEmSZp5+iYVNA8bp1irhQZm5H2X8hX+OiIMGrpkkSZIkSZrx+g3euAZY
3PJ+MaVFQq8ye1fTyMwrqv/XRsS5lK4VF3Vb2R577MacObM3v5+YGOtTvWLBgjEWLZrXs4yxjDVd
sQaNYyxj7YyxRnW/NpaxpjPWqO/XxjLWdMYa1f3aWMZqGmeUY7Xql1i4BFgWEUuAK4AjgeVtZc4D
jgPOiYgDgWsy8/cRsRswOzOvi4hbAYcAb+i1somJ67d4v27d+oE+xLp161m79rq+ZYxlrOmINWgc
YxlrZ4w1qvu1sYw1nbFGfb82lrGmM9ao7tfGMlbTOKMWq1uioWdXiMy8gZI0uAD4OfCpzFwZEcdG
xLFVmS8Bl0fEZcAK4PnV4nsCF0XEj4DvA/+RmV8Z+FNIkiRJkqQZr1+LBTLzfOD8tmkr2t4f12G5
y4H7TLWCkiRJkiRp5uo3eKMkSZIkSVJXJhYkSZIkSVJjJhYkSZIkSVJjJhYkSZIkSVJjJhYkSZIk
SVJjJhYkSZIkSVJjJhYkSZIkSVJjJhYkSZIkSVJjJhYkSZIkSVJjJhYkSZIkSVJjJhYkSZIkSVJj
JhYkSZIkSVJjJhYkSZIkSVJjJhYkSZIkSVJjJhYkSZIkSVJjJhYkSZIkSVJjJhYkSZIkSVJjJhYk
SZIkSVJjJhYkSZIkSVJjJhYkSZIkSVJjJhYkSZIkSVJjJhYkSZIkSVJjJhYkSZIkSVJjJhYkSZIk
SVJjJhYkSZIkSVJjJhYkSZIkSVJjc/oViIhDgdOA2cCZmXlyhzLvAR4FXA88PTN/OOiykiRJkiRp
dPVssRARs4HTgUOBuwPLI+JubWX+AbhzZi4DngO8f9BlJUmSJEnSaOvXFWJ/4LLMXJWZG4FzgMPa
yvwT8DGAzPw+MD8i9hxwWUmSJEmSNML6dYXYCxhvef874IAByuwF3GGAZbdwv/vdc4v3Gzdu5Jpr
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
"
/>

</div>
</div>
</div>

  </div>
</div>
<div class="cell border-box-sizing text_cell rendered">
  <div class="prompt input_prompt"></div>
  <div class="inner_cell">
    <div class="text_cell_render border-box-sizing rendered_html">
      <p>
        Similarly, when we look at destination states ranked by percentage of
        arrivals delayed, we see some new states at the head of the list. For
        instance, Delaware, second to last in the total number of delays
        overall, has the highest percentage of arrival delays for inbound
        flights. Iowa and Kansas are also new entries near the top.
      </p>
    </div>
  </div>
</div>
<div class="cell border-box-sizing code_cell rendered">
  <div class="input">
    <div class="prompt input_prompt">In&nbsp;[27]:</div>
    <div class="inner_cell">
      <div class="input_area">
        <div class="highlight hl-ipython3">
          <pre><span></span><span class="n">pct_arrival_delay</span><span class="o">.</span><span class="n">order</span><span class="p">(</span><span class="n">ascending</span><span class="o">=</span><span class="kc">False</span><span class="p">)</span><span class="o">.</span><span class="n">plot</span><span class="p">(</span><span class="n">kind</span><span class="o">=</span><span class="s1">&#39;bar&#39;</span><span class="p">,</span> <span class="n">color</span><span class="o">=</span><span class="n">colors</span><span class="p">[</span><span class="mi">1</span><span class="p">],</span> <span class="n">title</span><span class="o">=</span><span class="s1">&#39;</span><span class="si">% f</span><span class="s1">lights with arrival delay by destination state&#39;</span><span class="p">)</span>
</pre>
        </div>
      </div>
    </div>
  </div>

  <div class="output_wrapper">
    <div class="output">
      <div class="output_area">
        <div class="prompt output_prompt">Out[27]:</div>

        <div class="output_text output_subarea output_execute_result">
          <pre>

&lt;matplotlib.axes.\_subplots.AxesSubplot at 0x7f67ad3fec10&gt;</pre
          >

</div>
</div>

      <div class="output_area">
        <div class="prompt"></div>

        <div class="output_png output_subarea">
          <img
            src="data:image/png;base64,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
X80LI+IWyvOfT590jSVJO7TqKQ7Lprsemh6Z+dw+xbmRMj6GJEmaYp0SC92MYHwq5Zngo9WjjBpb
KDyiGil6CPhqRPwiMy9qHQZuvvmW0TlzZnfxlpIkSZIkaTtr2SOhU2JhPeOfH76Y0mqh0UOBs0qX
WO4MHBIRWzJzdWZeC5CZG6pnLy9n/LPAxxkZualDdYqhoQVs2LCpq7I7e6yZWCdjGctYxjJWf2PN
xDoZy1jGMpaxZm6smVgnYw1GrKGhBS3nd0osXAosi4glwDWUxzmtbCyQmfccex0RHwa+kJmrI2I3
YHZmbqr6OR4MvLFjTSVJkiRJ0sDYZaKF1bOOj6E8t/py4NOZuTYijo6IozvE3gu4KCIuAy4GvpiZ
F/Sj0pIkSZIkaWbo1GKBzFwDrGmat6pN2ec1vL4SePBkKyhJkiRJkmauCVssSJIkSZIkTcTEgiRJ
kiRJqs3EgiRJkiRJqs3EgiRJkiRJqs3EgiRJkiRJqs3EgiRJkiRJqs3EgiRJkiRJqs3EgiRJkiRJ
qs3EgiRJkiRJqs3EgiRJkiRJqs3EgiRJkiRJqs3EgiRJkiRJqs3EgiRJkiRJqs3EgiRJkiRJqs3E
giRJkiRJqs3EgiRJkiRJqs3EgiRJkiRJqs3EgiRJkiRJqs3EgiRJkiRJqs3EgiRJkiRJqs3EgiRJ
kiRJqs3EgiRJkiRJqm1OpwIRsQI4FZgNnJGZJ7Up93Dg+8Dhmfn5XtaVJEmSJEmDacIWCxExGzgN
WAHcD1gZEfdtU+4k4Cu9ritJkiRJkgZXp64Qy4ErMnNdZm4BzgIOa1HuWOBzwIYa60qSJEmSpAHV
qSvEImC4YfpqYP/GAhGxiJIweCzwcGC023U72bx5M8PDV20zf2RkPhs33rB1evHifZk7d24voSVJ
kiRJUh/MGh0dbbswIp4GrMjMF1bTzwb2z8xjG8p8FjglMy+OiI8AX8jMz3ezbrObb75ldM6c2Vun
f/nLX/KCj7yCeUML2tbxxg2bOOPId3Lve9+7u08sSZIkSZLqmNVqZqcWC+uBxQ3TiyktDxo9FDgr
IgDuDBwSEVu6XHeckZGbxk1v3HgD84YWsGDvPSas5MaNN7Bhw6YJy7QzNLSg9rqDEGsm1slYxjKW
sYzV31gzsU7GMpaxjGWsmRtrJtbJWIMRa6jNTf9OiYVLgWURsQS4BjgcWNlYIDPvOfY6Ij5MabGw
OiLmdFpXkiRJkiQNtgkHb8zMm4FjgPOBy4FPZ+baiDg6Io6us25/qi1JkiRJkmaCTi0WyMw1wJqm
eavalH1ep3UlSZIkSdKOo9PjJiVJkiRJktoysSBJkiRJkmozsSBJkiRJkmozsSBJkiRJkmozsSBJ
kiRJkmozsSBJkiRJkmozsSBJkiRJkmozsSBJkiRJkmozsSBJkiRJkmozsSBJkiRJkmozsSBJkiRJ
kmozsSBJkiRJkmozsSBJkiRJkmozsSBJkiRJkmozsSBJkiRJkmozsSBJkiRJkmozsSBJkiRJkmoz
sSBJkiRJkmqbM90V2F42b97M8PBV28wfGZnPxo03bJ1evHhf5s6duz2rJkmSJEnSwNppEgvDw1dx
/OrXM29oQdsyN27YxMmHnsjSpcu2Y80kSZIkSRpcO01iAWDe0AIW7L3HdFdDkiRJkqQdxk6VWOgX
u1VIkiRJklR0TCxExArgVGA2cEZmntS0/DDgRODW6t+rMvPr1bJ1wJ+AW4Atmbm8n5WfLnarkCRJ
kiSpmDCxEBGzgdOAg4D1wCURsToz1zYUuzAzz6vKPxA4B7hXtWwUODAzN/a95tPMbhWSJEmSJHV+
3ORy4IrMXJeZW4CzgMMaC2TmjQ2T84HfN8WYNelaSpIkSZKkGalTV4hFwHDD9NXA/s2FIuLJwFuB
uwEHNywaBS6MiFuAVZl5+uSqK0mSJEmSZpJOiYXRboJk5rnAuRHxKODjQFSLHpGZ10bEEPDViPhF
Zl7ULs6ee+7GnDmzt06PjMzv5u1ZuHA+QxOMdzCTY01kMutORRxjGctYxjLWzI01E+tkLGMZy1jG
mrmxZmKdjDW4sTolFtYDixumF1NaLbSUmRdFxJyIuFNm/iEzr63mb4iIcyhdK9omFkZGbho33fiE
hYls3HgDGzZs6lhmJsZqZ2hoQe11pyKOsYxlLGMZa+bGmol1MpaxjGUsY83cWDOxTsYajFjtkg+d
xli4FFgWEUsiYi5wOLC6sUBELI2IWdXrhwBk5h8iYreIWFDNn0fpIvHTjjWVJEmSJEkDY8IWC5l5
c0QcA5xPedzkBzNzbUQcXS1fBTwNeE5EbAFuAI6oVt8LODsixt7nk5l5wdR8DEmSJEmSNB06dYUg
M9cAa5rmrWp4fTJwcov1rgQe3Ic6SpIkSZKkGapjYkFTa/PmzQwPX7XN/JGR+ePGcli8eF/mzp27
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
JKk2EwuSJEmSJKk2EwuSJEmSJKk2EwuSJEmSJKk2EwuSJEmSJKk2EwuSJEmSJKk2EwuSJEmSJKk2
EwuSJEmSJKk2EwuSJEmSJKk2EwuSJEmSJKk2EwuSJEmSJKk2EwuSJEmSJKm2OZ0KRMQK4FRgNnBG
Zp7UtPw+wIeB/YDXZOY7ul1XkiRJkiQNtglbLETEbOA0YAVwP2BlRNy3qdgfgGOBU2qsK0mSJEmS
BlinrhDLgSsyc11mbgHOAg5rLJCZGzLzUmBLr+tKkiRJkqTB1imxsAgYbpi+uprXjcmsK0mSJEmS
BkCnMRZGJxG753X33HM35syZvXV6ZGR+V+stXDifoaEFE5YxlrGmKla3cYxlrJ0x1qDu18Yy1lTG
GvT92ljGmspYg7pfG8tYdeNs71gTqbsedE4srAcWN0wvprQ86EbP646M3DRueuPGG7p6o40bb2DD
hk0dyxjLWFMRq9s4xjLWzhhrUPdrYxlrKmMN+n5tLGNNZaxB3a+NZay6cbZ3rHaGhhZ0tV675EOn
xMKlwLKIWAJcAxwOrGxTdtYk1pUkSZIkSQNowsRCZt4cEccA51MeGfnBzFwbEUdXy1dFxF7AJcDu
wK0R8TLgfpl5Q6t1p/LDSJIkSZKk7atTiwUycw2wpmneqobX1zG+y8OE60qSJEmSpB1Hp6dCSJIk
SZIktWViQZIkSZIk1daxK4QkSZIkSRp8mzdvZnj4qm3mj4zM3+bpE4sX78vcuXO7imtiQZIkSZKk
ncDw8FUcv/r1zGvz2MgxN27YxMmHnsjSpcu6imtiQZIkSZKkncS8oQUs2HuPvsZ0jAVJkiRJklSb
iQVJkiRJklSbiQVJkiRJklSbiQVJkiRJklSbiQVJkiRJklSbiQVJkiRJklSbiQVJkiRJklSbiQVJ
kiRJklSbiQVJkiRJklSbiQVJkiRJklSbiQVJkiRJklSbiQVJkiRJklSbiQVJkiRJklSbiQVJkiRJ
klSbiQVJkiRJklSbiQVJkiRJklSbiQVJkiRJklTbnE4FImIFcCowGzgjM09qUeY9wCHATcCRmfmj
av464E/ALcCWzFzet5pLkiRJkqRpN2GLhYiYDZwGrADuB6yMiPs2lXkCcK/MXAa8CHh/w+JR4MDM
3M+kgiRJkiRJO55OXSGWA1dk5rrM3AKcBRzWVOZQ4KMAmXkxsEdE3LVh+ax+VVaSJEmSJM0snRIL
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
WJxEM0W3ZYsAAAAASUVORK5CYII=
"
/>

</div>
</div>
</div>

  </div>
</div>
<div class="cell border-box-sizing text_cell rendered">
  <div class="prompt input_prompt"></div>
  <div class="inner_cell">
    <div class="text_cell_render border-box-sizing rendered_html">
      <p>
        We can get a sense of the difference between the two percentages for
        each state by plotting them on the same axes. In the plot below, we find
        that most states see more arrival delays than departure delays. The
        disparity seems greatest for smaller, less populated states that don't
        have huge airports (e.g., DE, IA, RI). We can't say for sure without
        studying more data or perhaps correlating the disparity with the state's
        ranking in terms of the total number of flights it serviced. We'll leave
        that as an exercise for the future.
      </p>
    </div>
  </div>
</div>
<div class="cell border-box-sizing code_cell rendered">
  <div class="input">
    <div class="prompt input_prompt">In&nbsp;[28]:</div>
    <div class="inner_cell">
      <div class="input_area">
        <div class="highlight hl-ipython3">
          <pre><span></span><span class="n">pct_delay_df</span> <span class="o">=</span> <span class="n">pandas</span><span class="o">.</span><span class="n">DataFrame</span><span class="p">([</span><span class="n">pct_departure_delay</span><span class="p">,</span> <span class="n">pct_arrival_delay</span><span class="p">],</span> <span class="n">index</span><span class="o">=</span><span class="p">[</span><span class="s1">&#39;PCT_DEP_DEL15&#39;</span><span class="p">,</span> <span class="s1">&#39;PCT_ARR_DEL15&#39;</span><span class="p">])</span><span class="o">.</span><span class="n">T</span>
</pre>
        </div>
      </div>
    </div>
  </div>
</div>
<div class="cell border-box-sizing code_cell rendered">
  <div class="input">
    <div class="prompt input_prompt">In&nbsp;[29]:</div>
    <div class="inner_cell">
      <div class="input_area">
        <div class="highlight hl-ipython3">
          <pre><span></span><span class="n">pct_delay_df</span><span class="o">.</span><span class="n">sort</span><span class="p">(</span><span class="s1">&#39;PCT_ARR_DEL15&#39;</span><span class="p">,</span> <span class="n">ascending</span><span class="o">=</span><span class="kc">False</span><span class="p">)</span><span class="o">.</span><span class="n">plot</span><span class="p">(</span><span class="n">kind</span><span class="o">=</span><span class="s1">&#39;bar&#39;</span><span class="p">,</span> <span class="n">title</span><span class="o">=</span><span class="s1">&#39;Overlapping </span><span class="si">% d</span><span class="s1">elay plots for comparison&#39;</span><span class="p">)</span>
</pre>
        </div>
      </div>
    </div>
  </div>

  <div class="output_wrapper">
    <div class="output">
      <div class="output_area">
        <div class="prompt output_prompt">Out[29]:</div>

        <div class="output_text output_subarea output_execute_result">
          <pre>

&lt;matplotlib.axes.\_subplots.AxesSubplot at 0x7f67a96854d0&gt;</pre
          >

</div>
</div>

      <div class="output_area">
        <div class="prompt"></div>

        <div class="output_png output_subarea">
          <img
            src="data:image/png;base64,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
ED94iWmlAAAAAElFTkSuQmCC
"
/>

</div>
</div>
</div>

  </div>
</div>
<div class="cell border-box-sizing text_cell rendered">
  <div class="prompt input_prompt"></div>
  <div class="inner_cell">
    <div class="text_cell_render border-box-sizing rendered_html">
      <h2 id="Delay-Tendency">
        Delay Tendency<a class="anchor-link" href="#Delay-Tendency">&#182;</a>
      </h2>
      <blockquote>
        <p>
          Is there a tendency of flights from one state to another to experience
          a delay of 15 minutes or more on the arriving end?
        </p>
      </blockquote>
      <p>
        While there are many ways to answer this question, we'll look at
        visualizations of two metrics:
      </p>
      <ol>
        <li>
          How many times does a delay occur for an (origin &rarr; destination)
          state pair over all flights during the time period? (This is the
          <a
            href="http://en.wikipedia.org/wiki/Association_rule_learning#Useful_Concepts"
            >support of a simple association rule</a
          >.)
        </li>
        <li>
          What percentage of total flights from an origin to a destination are
          delayed during the time period?
        </li>
      </ol>
      <p>
        First, we'll compute the support. We do so by grouping all of the
        arrival delay counts by the origin and destination.
      </p>
    </div>
  </div>
</div>
<div class="cell border-box-sizing code_cell rendered">
  <div class="input">
    <div class="prompt input_prompt">In&nbsp;[30]:</div>
    <div class="inner_cell">
      <div class="input_area">
        <div class="highlight hl-ipython3">
          <pre><span></span><span class="kn">from</span> <span class="nn">__future__</span> <span class="k">import</span> <span class="n">division</span>
</pre>
        </div>
      </div>
    </div>
  </div>
</div>
<div class="cell border-box-sizing code_cell rendered">
  <div class="input">
    <div class="prompt input_prompt">In&nbsp;[31]:</div>
    <div class="inner_cell">
      <div class="input_area">
        <div class="highlight hl-ipython3">
          <pre><span></span><span class="n">delay_counts_df</span> <span class="o">=</span> <span class="n">df</span><span class="p">[[</span><span class="s1">&#39;ORIGIN_STATE_ABR&#39;</span><span class="p">,</span> <span class="s1">&#39;DEST_STATE_ABR&#39;</span><span class="p">,</span> <span class="s1">&#39;ARR_DEL15&#39;</span><span class="p">]]</span><span class="o">.</span><span class="n">groupby</span><span class="p">([</span><span class="s1">&#39;ORIGIN_STATE_ABR&#39;</span><span class="p">,</span> <span class="s1">&#39;DEST_STATE_ABR&#39;</span><span class="p">])</span><span class="o">.</span><span class="n">sum</span><span class="p">()</span>
<span class="n">delay_counts_df</span><span class="o">.</span><span class="n">head</span><span class="p">()</span>
</pre>
        </div>
      </div>
    </div>
  </div>

  <div class="output_wrapper">
    <div class="output">
      <div class="output_area">
        <div class="prompt output_prompt">Out[31]:</div>

        <div
          class="output_html rendered_html output_subarea output_execute_result"
        >
          <div style="max-height: 1000px; max-width: 1500px; overflow: auto">
            <table border="1" class="dataframe">
              <thead>
                <tr style="text-align: right">
                  <th></th>
                  <th></th>
                  <th>ARR_DEL15</th>
                </tr>
                <tr>
                  <th>ORIGIN_STATE_ABR</th>
                  <th>DEST_STATE_ABR</th>
                  <th></th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <th rowspan="5" valign="top">AK</th>
                  <th>AK</th>
                  <td>351</td>
                </tr>
                <tr>
                  <th>AZ</th>
                  <td>5</td>
                </tr>
                <tr>
                  <th>CA</th>
                  <td>11</td>
                </tr>
                <tr>
                  <th>CO</th>
                  <td>21</td>
                </tr>
                <tr>
                  <th>GA</th>
                  <td>3</td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>

  </div>
</div>
<div class="cell border-box-sizing text_cell rendered">
  <div class="prompt input_prompt"></div>
  <div class="inner_cell">
    <div class="text_cell_render border-box-sizing rendered_html">
      <p>
        We divide each (origin &rarr; destination) delay count by the total
        number of flights during the period.
      </p>
    </div>
  </div>
</div>
<div class="cell border-box-sizing code_cell rendered">
  <div class="input">
    <div class="prompt input_prompt">In&nbsp;[32]:</div>
    <div class="inner_cell">
      <div class="input_area">
        <div class="highlight hl-ipython3">
          <pre><span></span><span class="n">support</span> <span class="o">=</span> <span class="p">(</span><span class="n">delay_counts_df</span> <span class="o">/</span> <span class="nb">len</span><span class="p">(</span><span class="n">df</span><span class="p">))</span>
<span class="n">support</span><span class="o">.</span><span class="n">head</span><span class="p">()</span>
</pre>
        </div>
      </div>
    </div>
  </div>

  <div class="output_wrapper">
    <div class="output">
      <div class="output_area">
        <div class="prompt output_prompt">Out[32]:</div>

        <div
          class="output_html rendered_html output_subarea output_execute_result"
        >
          <div style="max-height: 1000px; max-width: 1500px; overflow: auto">
            <table border="1" class="dataframe">
              <thead>
                <tr style="text-align: right">
                  <th></th>
                  <th></th>
                  <th>ARR_DEL15</th>
                </tr>
                <tr>
                  <th>ORIGIN_STATE_ABR</th>
                  <th>DEST_STATE_ABR</th>
                  <th></th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <th rowspan="5" valign="top">AK</th>
                  <th>AK</th>
                  <td>0.000699</td>
                </tr>
                <tr>
                  <th>AZ</th>
                  <td>0.000010</td>
                </tr>
                <tr>
                  <th>CA</th>
                  <td>0.000022</td>
                </tr>
                <tr>
                  <th>CO</th>
                  <td>0.000042</td>
                </tr>
                <tr>
                  <th>GA</th>
                  <td>0.000006</td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>

  </div>
</div>
<div class="cell border-box-sizing text_cell rendered">
  <div class="prompt input_prompt"></div>
  <div class="inner_cell">
    <div class="text_cell_render border-box-sizing rendered_html">
      <p>
        We unstack the multiple indices so that we have a N x N matrix with
        origins as rows and destinations as columns.
      </p>
    </div>
  </div>
</div>
<div class="cell border-box-sizing code_cell rendered">
  <div class="input">
    <div class="prompt input_prompt">In&nbsp;[33]:</div>
    <div class="inner_cell">
      <div class="input_area">
        <div class="highlight hl-ipython3">
          <pre><span></span><span class="n">support</span> <span class="o">=</span> <span class="n">support</span><span class="o">.</span><span class="n">unstack</span><span class="p">()</span>
<span class="n">support</span><span class="o">.</span><span class="n">head</span><span class="p">()</span>
</pre>
        </div>
      </div>
    </div>
  </div>

  <div class="output_wrapper">
    <div class="output">
      <div class="output_area">
        <div class="prompt output_prompt">Out[33]:</div>

        <div
          class="output_html rendered_html output_subarea output_execute_result"
        >
          <div style="max-height: 1000px; max-width: 1500px; overflow: auto">
            <table border="1" class="dataframe">
              <thead>
                <tr>
                  <th></th>
                  <th colspan="21" halign="left">ARR_DEL15</th>
                </tr>
                <tr>
                  <th>DEST_STATE_ABR</th>
                  <th>AK</th>
                  <th>AL</th>
                  <th>AR</th>
                  <th>AZ</th>
                  <th>CA</th>
                  <th>CO</th>
                  <th>CT</th>
                  <th>DE</th>
                  <th>FL</th>
                  <th>GA</th>
                  <th>...</th>
                  <th>TT</th>
                  <th>TX</th>
                  <th>UT</th>
                  <th>VA</th>
                  <th>VI</th>
                  <th>VT</th>
                  <th>WA</th>
                  <th>WI</th>
                  <th>WV</th>
                  <th>WY</th>
                </tr>
                <tr>
                  <th>ORIGIN_STATE_ABR</th>
                  <th></th>
                  <th></th>
                  <th></th>
                  <th></th>
                  <th></th>
                  <th></th>
                  <th></th>
                  <th></th>
                  <th></th>
                  <th></th>
                  <th></th>
                  <th></th>
                  <th></th>
                  <th></th>
                  <th></th>
                  <th></th>
                  <th></th>
                  <th></th>
                  <th></th>
                  <th></th>
                  <th></th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <th>AK</th>
                  <td>0.000699</td>
                  <td>NaN</td>
                  <td>NaN</td>
                  <td>0.000010</td>
                  <td>0.000022</td>
                  <td>0.000042</td>
                  <td>NaN</td>
                  <td>NaN</td>
                  <td>NaN</td>
                  <td>0.000006</td>
                  <td>...</td>
                  <td>NaN</td>
                  <td>0.000050</td>
                  <td>0.000004</td>
                  <td>NaN</td>
                  <td>NaN</td>
                  <td>NaN</td>
                  <td>0.000209</td>
                  <td>NaN</td>
                  <td>NaN</td>
                  <td>NaN</td>
                </tr>
                <tr>
                  <th>AL</th>
                  <td>NaN</td>
                  <td>NaN</td>
                  <td>NaN</td>
                  <td>NaN</td>
                  <td>NaN</td>
                  <td>0.000064</td>
                  <td>NaN</td>
                  <td>NaN</td>
                  <td>0.000080</td>
                  <td>0.000364</td>
                  <td>...</td>
                  <td>NaN</td>
                  <td>0.000631</td>
                  <td>NaN</td>
                  <td>0.000018</td>
                  <td>NaN</td>
                  <td>NaN</td>
                  <td>NaN</td>
                  <td>NaN</td>
                  <td>NaN</td>
                  <td>NaN</td>
                </tr>
                <tr>
                  <th>AR</th>
                  <td>NaN</td>
                  <td>NaN</td>
                  <td>NaN</td>
                  <td>0.000008</td>
                  <td>0.000036</td>
                  <td>0.000098</td>
                  <td>NaN</td>
                  <td>NaN</td>
                  <td>NaN</td>
                  <td>0.000163</td>
                  <td>...</td>
                  <td>NaN</td>
                  <td>0.000826</td>
                  <td>0.000002</td>
                  <td>NaN</td>
                  <td>NaN</td>
                  <td>NaN</td>
                  <td>NaN</td>
                  <td>NaN</td>
                  <td>NaN</td>
                  <td>NaN</td>
                </tr>
                <tr>
                  <th>AZ</th>
                  <td>0.000026</td>
                  <td>NaN</td>
                  <td>0.000008</td>
                  <td>0.000129</td>
                  <td>0.002559</td>
                  <td>0.000352</td>
                  <td>NaN</td>
                  <td>NaN</td>
                  <td>0.000086</td>
                  <td>0.000113</td>
                  <td>...</td>
                  <td>NaN</td>
                  <td>0.000722</td>
                  <td>0.000239</td>
                  <td>0.000072</td>
                  <td>NaN</td>
                  <td>NaN</td>
                  <td>0.000291</td>
                  <td>0.000062</td>
                  <td>NaN</td>
                  <td>NaN</td>
                </tr>
                <tr>
                  <th>CA</th>
                  <td>0.000056</td>
                  <td>NaN</td>
                  <td>0.000008</td>
                  <td>0.001847</td>
                  <td>0.011355</td>
                  <td>0.001409</td>
                  <td>0.000014</td>
                  <td>NaN</td>
                  <td>0.000302</td>
                  <td>0.000344</td>
                  <td>...</td>
                  <td>NaN</td>
                  <td>0.002113</td>
                  <td>0.000557</td>
                  <td>0.000406</td>
                  <td>NaN</td>
                  <td>NaN</td>
                  <td>0.001423</td>
                  <td>0.000068</td>
                  <td>NaN</td>
                  <td>0</td>
                </tr>
              </tbody>
            </table>
            <p>5 rows × 53 columns</p>
          </div>
        </div>
      </div>
    </div>

  </div>
</div>
<div class="cell border-box-sizing text_cell rendered">
  <div class="prompt input_prompt"></div>
  <div class="inner_cell">
    <div class="text_cell_render border-box-sizing rendered_html">
      <p>
        Unfortunately, we now have a multilevel set of columns. One way to
        remove the outer level is to rotate the matrix, reset the outer index to
        drop it, and then rotate it back.
      </p>
      <p>
        In the resulting matrix, each cell represents the proportion of total,
        system-wide flights that were delayed between an (origin &rarr;
        destination) pair.
      </p>
    </div>
  </div>
</div>
<div class="cell border-box-sizing code_cell rendered">
  <div class="input">
    <div class="prompt input_prompt">In&nbsp;[34]:</div>
    <div class="inner_cell">
      <div class="input_area">
        <div class="highlight hl-ipython3">
          <pre><span></span><span class="n">support</span> <span class="o">=</span> <span class="n">support</span><span class="o">.</span><span class="n">T</span><span class="o">.</span><span class="n">reset_index</span><span class="p">(</span><span class="n">level</span><span class="o">=</span><span class="mi">0</span><span class="p">,</span> <span class="n">drop</span><span class="o">=</span><span class="kc">True</span><span class="p">)</span><span class="o">.</span><span class="n">T</span>
<span class="n">support</span><span class="o">.</span><span class="n">head</span><span class="p">()</span>
</pre>
        </div>
      </div>
    </div>
  </div>

  <div class="output_wrapper">
    <div class="output">
      <div class="output_area">
        <div class="prompt output_prompt">Out[34]:</div>

        <div
          class="output_html rendered_html output_subarea output_execute_result"
        >
          <div style="max-height: 1000px; max-width: 1500px; overflow: auto">
            <table border="1" class="dataframe">
              <thead>
                <tr style="text-align: right">
                  <th>DEST_STATE_ABR</th>
                  <th>AK</th>
                  <th>AL</th>
                  <th>AR</th>
                  <th>AZ</th>
                  <th>CA</th>
                  <th>CO</th>
                  <th>CT</th>
                  <th>DE</th>
                  <th>FL</th>
                  <th>GA</th>
                  <th>...</th>
                  <th>TT</th>
                  <th>TX</th>
                  <th>UT</th>
                  <th>VA</th>
                  <th>VI</th>
                  <th>VT</th>
                  <th>WA</th>
                  <th>WI</th>
                  <th>WV</th>
                  <th>WY</th>
                </tr>
                <tr>
                  <th>ORIGIN_STATE_ABR</th>
                  <th></th>
                  <th></th>
                  <th></th>
                  <th></th>
                  <th></th>
                  <th></th>
                  <th></th>
                  <th></th>
                  <th></th>
                  <th></th>
                  <th></th>
                  <th></th>
                  <th></th>
                  <th></th>
                  <th></th>
                  <th></th>
                  <th></th>
                  <th></th>
                  <th></th>
                  <th></th>
                  <th></th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <th>AK</th>
                  <td>0.000699</td>
                  <td>NaN</td>
                  <td>NaN</td>
                  <td>0.000010</td>
                  <td>0.000022</td>
                  <td>0.000042</td>
                  <td>NaN</td>
                  <td>NaN</td>
                  <td>NaN</td>
                  <td>0.000006</td>
                  <td>...</td>
                  <td>NaN</td>
                  <td>0.000050</td>
                  <td>0.000004</td>
                  <td>NaN</td>
                  <td>NaN</td>
                  <td>NaN</td>
                  <td>0.000209</td>
                  <td>NaN</td>
                  <td>NaN</td>
                  <td>NaN</td>
                </tr>
                <tr>
                  <th>AL</th>
                  <td>NaN</td>
                  <td>NaN</td>
                  <td>NaN</td>
                  <td>NaN</td>
                  <td>NaN</td>
                  <td>0.000064</td>
                  <td>NaN</td>
                  <td>NaN</td>
                  <td>0.000080</td>
                  <td>0.000364</td>
                  <td>...</td>
                  <td>NaN</td>
                  <td>0.000631</td>
                  <td>NaN</td>
                  <td>0.000018</td>
                  <td>NaN</td>
                  <td>NaN</td>
                  <td>NaN</td>
                  <td>NaN</td>
                  <td>NaN</td>
                  <td>NaN</td>
                </tr>
                <tr>
                  <th>AR</th>
                  <td>NaN</td>
                  <td>NaN</td>
                  <td>NaN</td>
                  <td>0.000008</td>
                  <td>0.000036</td>
                  <td>0.000098</td>
                  <td>NaN</td>
                  <td>NaN</td>
                  <td>NaN</td>
                  <td>0.000163</td>
                  <td>...</td>
                  <td>NaN</td>
                  <td>0.000826</td>
                  <td>0.000002</td>
                  <td>NaN</td>
                  <td>NaN</td>
                  <td>NaN</td>
                  <td>NaN</td>
                  <td>NaN</td>
                  <td>NaN</td>
                  <td>NaN</td>
                </tr>
                <tr>
                  <th>AZ</th>
                  <td>0.000026</td>
                  <td>NaN</td>
                  <td>0.000008</td>
                  <td>0.000129</td>
                  <td>0.002559</td>
                  <td>0.000352</td>
                  <td>NaN</td>
                  <td>NaN</td>
                  <td>0.000086</td>
                  <td>0.000113</td>
                  <td>...</td>
                  <td>NaN</td>
                  <td>0.000722</td>
                  <td>0.000239</td>
                  <td>0.000072</td>
                  <td>NaN</td>
                  <td>NaN</td>
                  <td>0.000291</td>
                  <td>0.000062</td>
                  <td>NaN</td>
                  <td>NaN</td>
                </tr>
                <tr>
                  <th>CA</th>
                  <td>0.000056</td>
                  <td>NaN</td>
                  <td>0.000008</td>
                  <td>0.001847</td>
                  <td>0.011355</td>
                  <td>0.001409</td>
                  <td>0.000014</td>
                  <td>NaN</td>
                  <td>0.000302</td>
                  <td>0.000344</td>
                  <td>...</td>
                  <td>NaN</td>
                  <td>0.002113</td>
                  <td>0.000557</td>
                  <td>0.000406</td>
                  <td>NaN</td>
                  <td>NaN</td>
                  <td>0.001423</td>
                  <td>0.000068</td>
                  <td>NaN</td>
                  <td>0</td>
                </tr>
              </tbody>
            </table>
            <p>5 rows × 53 columns</p>
          </div>
        </div>
      </div>
    </div>

  </div>
</div>
<div class="cell border-box-sizing text_cell rendered">
  <div class="prompt input_prompt"></div>
  <div class="inner_cell">
    <div class="text_cell_render border-box-sizing rendered_html">
      <p>
        At this point, we have a DataFrame that we can query but no clear idea
        of where to start looking. A visualization of the entire DataFrame can
        help us find interesting pairs. We borrow and slightly modify some code
        from <code>seaborn</code> to plot our asymmetric matrix as a heatmap.
      </p>
    </div>
  </div>
</div>
<div class="cell border-box-sizing code_cell rendered">
  <div class="input">
    <div class="prompt input_prompt">In&nbsp;[37]:</div>
    <div class="inner_cell">
      <div class="input_area">
        <div class="highlight hl-ipython3">
          <pre><span></span><span class="kn">import</span> <span class="nn">numpy</span> <span class="k">as</span> <span class="nn">np</span>
</pre>
        </div>
      </div>
    </div>
  </div>
</div>
<div class="cell border-box-sizing code_cell rendered">
  <div class="input">
    <div class="prompt input_prompt">In&nbsp;[38]:</div>
    <div class="inner_cell">
      <div class="input_area">
        <div class="highlight hl-ipython3">
          <pre><span></span><span class="k">def</span> <span class="nf">asymmatplot</span><span class="p">(</span><span class="n">plotmat</span><span class="p">,</span> <span class="n">names</span><span class="o">=</span><span class="kc">None</span><span class="p">,</span> <span class="n">cmap</span><span class="o">=</span><span class="s2">&quot;Greys&quot;</span><span class="p">,</span> <span class="n">cmap_range</span><span class="o">=</span><span class="kc">None</span><span class="p">,</span> <span class="n">ax</span><span class="o">=</span><span class="kc">None</span><span class="p">,</span> <span class="o">**</span><span class="n">kwargs</span><span class="p">):</span>
    <span class="sd">&#39;&#39;&#39;</span>
<span class="sd">    Plot an asymmetric matrix with colormap and statistic values. A modification of the</span>
<span class="sd">    symmatplot() function in Seaborn to show the upper-half of the matrix.</span>
<span class="sd">    </span>
<span class="sd">    See https://github.com/mwaskom/seaborn/blob/master/seaborn/linearmodels.py for the original.</span>
<span class="sd">    &#39;&#39;&#39;</span>
    <span class="k">if</span> <span class="n">ax</span> <span class="ow">is</span> <span class="kc">None</span><span class="p">:</span>
        <span class="n">ax</span> <span class="o">=</span> <span class="n">plt</span><span class="o">.</span><span class="n">gca</span><span class="p">()</span>

    <span class="n">nvars</span> <span class="o">=</span> <span class="nb">len</span><span class="p">(</span><span class="n">plotmat</span><span class="p">)</span>

    <span class="k">if</span> <span class="n">cmap_range</span> <span class="ow">is</span> <span class="kc">None</span><span class="p">:</span>
        <span class="n">vmax</span> <span class="o">=</span> <span class="n">np</span><span class="o">.</span><span class="n">nanmax</span><span class="p">(</span><span class="n">plotmat</span><span class="p">)</span> <span class="o">*</span> <span class="mf">1.15</span>
        <span class="n">vmin</span> <span class="o">=</span> <span class="n">np</span><span class="o">.</span><span class="n">nanmin</span><span class="p">(</span><span class="n">plotmat</span><span class="p">)</span> <span class="o">*</span> <span class="mf">1.15</span>
    <span class="k">elif</span> <span class="nb">len</span><span class="p">(</span><span class="n">cmap_range</span><span class="p">)</span> <span class="o">==</span> <span class="mi">2</span><span class="p">:</span>
        <span class="n">vmin</span><span class="p">,</span> <span class="n">vmax</span> <span class="o">=</span> <span class="n">cmap_range</span>
    <span class="k">else</span><span class="p">:</span>
        <span class="k">raise</span> <span class="ne">ValueError</span><span class="p">(</span><span class="s2">&quot;cmap_range argument not understood&quot;</span><span class="p">)</span>

    <span class="n">mat_img</span> <span class="o">=</span> <span class="n">ax</span><span class="o">.</span><span class="n">matshow</span><span class="p">(</span><span class="n">plotmat</span><span class="p">,</span> <span class="n">cmap</span><span class="o">=</span><span class="n">cmap</span><span class="p">,</span> <span class="n">vmin</span><span class="o">=</span><span class="n">vmin</span><span class="p">,</span> <span class="n">vmax</span><span class="o">=</span><span class="n">vmax</span><span class="p">,</span> <span class="o">**</span><span class="n">kwargs</span><span class="p">)</span>

    <span class="n">plt</span><span class="o">.</span><span class="n">colorbar</span><span class="p">(</span><span class="n">mat_img</span><span class="p">,</span> <span class="n">shrink</span><span class="o">=.</span><span class="mi">75</span><span class="p">)</span>

    <span class="n">ax</span><span class="o">.</span><span class="n">xaxis</span><span class="o">.</span><span class="n">set_ticks_position</span><span class="p">(</span><span class="s2">&quot;bottom&quot;</span><span class="p">)</span>
    <span class="n">ax</span><span class="o">.</span><span class="n">set_xticklabels</span><span class="p">(</span><span class="n">names</span><span class="p">,</span> <span class="n">rotation</span><span class="o">=</span><span class="mi">90</span><span class="p">)</span>
    <span class="n">ax</span><span class="o">.</span><span class="n">set_yticklabels</span><span class="p">(</span><span class="n">names</span><span class="p">)</span>

    <span class="n">minor_ticks</span> <span class="o">=</span> <span class="n">np</span><span class="o">.</span><span class="n">linspace</span><span class="p">(</span><span class="o">-.</span><span class="mi">5</span><span class="p">,</span> <span class="n">nvars</span> <span class="o">-</span> <span class="mf">1.5</span><span class="p">,</span> <span class="n">nvars</span><span class="p">)</span>
    <span class="n">ax</span><span class="o">.</span><span class="n">set_xticks</span><span class="p">(</span><span class="n">minor_ticks</span><span class="p">,</span> <span class="kc">True</span><span class="p">)</span>
    <span class="n">ax</span><span class="o">.</span><span class="n">set_yticks</span><span class="p">(</span><span class="n">minor_ticks</span><span class="p">,</span> <span class="kc">True</span><span class="p">)</span>
    <span class="n">major_ticks</span> <span class="o">=</span> <span class="n">np</span><span class="o">.</span><span class="n">linspace</span><span class="p">(</span><span class="mi">0</span><span class="p">,</span> <span class="n">nvars</span> <span class="o">-</span> <span class="mi">1</span><span class="p">,</span> <span class="n">nvars</span><span class="p">)</span>
    <span class="n">ax</span><span class="o">.</span><span class="n">set_xticks</span><span class="p">(</span><span class="n">major_ticks</span><span class="p">)</span>
    <span class="n">ax</span><span class="o">.</span><span class="n">set_yticks</span><span class="p">(</span><span class="n">major_ticks</span><span class="p">)</span>
    <span class="n">ax</span><span class="o">.</span><span class="n">grid</span><span class="p">(</span><span class="kc">False</span><span class="p">,</span> <span class="n">which</span><span class="o">=</span><span class="s2">&quot;major&quot;</span><span class="p">)</span>
    <span class="n">ax</span><span class="o">.</span><span class="n">grid</span><span class="p">(</span><span class="kc">True</span><span class="p">,</span> <span class="n">which</span><span class="o">=</span><span class="s2">&quot;minor&quot;</span><span class="p">,</span> <span class="n">linestyle</span><span class="o">=</span><span class="s2">&quot;-&quot;</span><span class="p">)</span>

    <span class="k">return</span> <span class="n">ax</span>

</pre>
        </div>
      </div>
    </div>
  </div>
</div>
<div class="cell border-box-sizing text_cell rendered">
  <div class="prompt input_prompt"></div>
  <div class="inner_cell">
    <div class="text_cell_render border-box-sizing rendered_html">
      <p>
        In the plot, gray boxes represent cases where there are no flights
        between the origin (row) and destination (column) states. We see mostly
        light yellowish boxes representing state pairs where delays occur, but
        in tiny numbers compared to the total number of system-wide flights.
      </p>
      <p>
        We do see a couple very hot spots, namely in the (CA &rarr; CA) and (TX
        &rarr; TX) cells. We also see a few moderately hot spots, for example
        (TX &rarr; CA) and (FL &rarr; NY). We can interpret these cells as
        indicators of where delays tend to occur most across the entire set of
        flights.
      </p>
    </div>
  </div>
</div>
<div class="cell border-box-sizing code_cell rendered">
  <div class="input">
    <div class="prompt input_prompt">In&nbsp;[39]:</div>
    <div class="inner_cell">
      <div class="input_area">
        <div class="highlight hl-ipython3">
          <pre><span></span><span class="n">fig</span><span class="p">,</span> <span class="n">ax</span> <span class="o">=</span> <span class="n">plt</span><span class="o">.</span><span class="n">subplots</span><span class="p">(</span><span class="n">figsize</span><span class="o">=</span><span class="p">(</span><span class="mi">18</span><span class="p">,</span><span class="mi">18</span><span class="p">))</span>
<span class="n">asymmatplot</span><span class="p">(</span><span class="n">support</span><span class="p">,</span> <span class="n">names</span><span class="o">=</span><span class="n">support</span><span class="o">.</span><span class="n">columns</span><span class="p">,</span> <span class="n">ax</span><span class="o">=</span><span class="n">ax</span><span class="p">,</span> <span class="n">cmap</span><span class="o">=</span><span class="s1">&#39;OrRd&#39;</span><span class="p">)</span>
</pre>
        </div>
      </div>
    </div>
  </div>

  <div class="output_wrapper">
    <div class="output">
      <div class="output_area">
        <div class="prompt output_prompt">Out[39]:</div>

        <div class="output_text output_subarea output_execute_result">
          <pre>

&lt;matplotlib.axes.\_subplots.AxesSubplot at 0x7f679b621890&gt;</pre
          >

</div>
</div>

      <div class="output_area">
        <div class="prompt"></div>

        <div class="output_png output_subarea">
          <img
            src="data:image/png;base64,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
GkwdLs5WvSZXqHttLD8H1GqmzinO1pxDatp1V/bOPqQ4O5jqbj8XlzuYOi6uVHbUc/Satj3W1x+v
uU4LlyRJkrRpHRed5P+3aTZkn+p/bdvebt/uR5KnZ4pyg8FUL7PM7ivKMr6jKltaZ6hf5/bQXUXZ
ZuI02kPThdlB79rHQr5me/WxXXe5rbuqd9/OA6PY1pupffVxfbssu6/7uLjO0MtjuY/Zhbzteu2z
XZZdfSxLy+i8kyxJkiRJKuPl1qO36k5yRJwOXA48GbgHuA94GvAN4Bzg3uHPdGY+f3RVlSRJkiRp
ba2qkxwRDfBB4B2Zeelw2ROAqcz8i4h4B/CRzPzA6KsqSZIkSdLaWu1I8rOBw5n51oUFmfmlJY/p
7Qe0JUmSJKlP7HyN3movYX888D/XoiKSJEmSJHVttZ3kDTm9uCRJkiRJo7Day62/CrxsLSoiSZIk
SVodZ7cevVVt08z8FHByRPzswrKIeEJEfP/IayZJkiRJ0jor+Z7kHwYuj4h/BcwCNwKvXnS/l2RL
kiRJknpp1Z3kzLwdePlR7vup6hpJkiRJklbE2a1Hz0vYJUmSJEkaspMsSZIkSdJQyWeSVWF6ZktR
bjA+4oqso6Y5oSK7+f6PU7O9utLXdt3HevexzrU22zp3ub5dld3HfVxaZ5ivdx/Xua9s1zrebb53
y2uvadtO59lyki9JkiRJXTguPs77X5tmQ/apXta2vd2+nY8kT0/PFOUGg6lNl2V2X1GW8R3F5S6U
3VW9u1jnrvbxQn4zrXPX23ozHcubdVub3fhlb7Zsl2VvtmyXZW+2bJdlV78mS8vovJMsSZIkSSrj
5dajt6pOckQcAb4EnAQ8ALwL+J3MbCPiWcAfATcsivxiZn5qRHWVJEmSJGlNrXYk+WBmPhEgIgbA
u4HtwGuH91+dmS8eXfUkSZIkSVo/xaPzmTkN/Bxw2aLFvf1wtiRJkiT1TbNBf/qs6jPJmXljRJww
HFUG+IGIuHbRQ34kM2+sKUOSJEmSpPUy6om7Pp2ZLxrxc0qSJEmStC6qJkOLiPOAI8NLryVJkiRJ
62hsg/70WXH9h5dY/z5wxeiqI0mSJElSd1Z7ufXE8DPH3/kKqMz8j8P7Wv7+Z5L/fWZ+YAT1lCRJ
kiRpza2qk5yZR318Zl4NnFpdI0mSJEnSivT90uaNyG0qSZIkSdKQnWRJkiRJkoZG/RVQ62rntkOF
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
jNBGHaUn+UYGk3E9ICJ2AI8CbgbuBJ4DXBERTxthv5IkSZKkIs2Evrpr1Y3kzPwosDUiXgAP7ko9
zwAAIABJREFUPAD6MuDtwMHhNn8H/HPg/4uIJ4w/u5IkSZIkrZ1RepIBzgd+MiL+FkgGjeNXDD/r
A2TmJ4EXA9dGxBnjyqgkSZIkSWttpOckZ+bXgOcu89HHhq+F7f4b8J11WZMkSZIkHVU3Z7eeaKP2
JEuSJEmSdNwaqSdZkiRJkjRB7EkeO3uSJUmSJEkaar0nuTdzuO0sFDjWI6OP4lt3lcVN96BfkW6L
Zue2FMX1pqBpNhen21bdqk5380PGk5ENoJv3D43K87x6tWXVNOX/d97F87Rr+6HCyJlOHu+GtWWm
OLTfP1IU19V+Peu1NND02214dbPVJ0mSJKnruvr/GQ9y5BP/aSLbVJu+7xc7W76t9yRzaF9Z3NRO
ZmfnikJ7vZmq2P78nqLYZvok+nf/bVnsiWfTP3hnWezWk4uPF+rLqya2pn60VbeK0x2mXVO/2jpP
nasf0M06UpnnNo4X2r0PbKh6XXOOa+NbvJ7qvs9ni2Kb6V51WXexbnYtdiG+6u+2NupIi/VjI9Zr
aTn+JlmSJEmSpKGRepIj4pHAG4HHMmhg/ynwcuApwJ8AXwIeCrw3M1853qxKkiRJkh7E2a3HbtU9
yRHRAO9l0AA+Gzgb2A68lsFvi/9HZp4LfC/wExHxxDXIryRJkiRJa2aU4dY/DMxn5jsAMvMIcAnw
c8DWhY0y8xDwN8Cjx5hPSZIkSZLW3CiN5HOATy1ekZlzwFeBMxfWRcTDge8DbhxHBiVJkiRJK2km
9NVdozSSjzW1+A9GxN8AtwLvy8zPl2dLkiRJkqT1N0oj+UbgQb8zjogdwKOAm4H/mZnfw6DH+Z9H
xO6x5VKSJEmSpHWw6kZyZn4U2BoRLwCIiM3AZcDbgYOLtrsF+I/AvxtrTiVJkiRJD9Y0k/nqsFGf
k3w+8JMR8bdAMmgcv2L42eLh2L8HPHP4yChJkiRJkjphpOckZ+bXgOcu89HHhq+F7Q4xGIYtSZIk
SVJnjNRIliRJkiRNkI4PbZ5Eow63liRJkiTpuNV6T/Ls3JaiuN7UmDOyXk6YbiXZ3szhVtIF2PXQ
fYWRM/TvO1QU2dBe3SpN94G0D+8vC54+qdXzXKomz/37y2MboN8/Uhxble/+/cXp1sR2Vf/IvUVx
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
2oltU1fzXWrvgbJfK43jXl9Vvyry3da1WKO0rKDdfNfcc7tq77fKpsnpUVdeXbx31X6vSseLpt9v
dQJqZ7+WJEmS1IbjYpxy/9aPTGSbqtn9jM6Wb+s9ybOzc0Vxvd6MsesQ22batbEc2lcUy9ROy/o4
j20z7Y0W22baxnYj7Y0W22baGy22zbQ3WmybaVf/vSgtw98kS5IkSZI0NHJPckTsBD4yXDwFuH/4
72eBLcP39wxfs5n5Y+PJqiRJkiTpwTo7qnlijdxIzsx9wLkAEfEqYC4zL1/4PCLeDrw/M987tlxK
kiRJkrQOxjHcern/uvC/MyRJkiRJndP6xF2SJEmSpEKN/ZPj5sRdkiRJkiQN2UiWJEmSJGnI4daS
JEmS1FWN/Z7jNo4S7a9ynSRJkiRJE62qJzkzX7PMuhfX7FOSJEmSpLY43FqSJEmSOsvZrcfNAeyS
JEmSJA3ZSJYkSZIkaajp91udY8sJviRJkiStv0P7YGpn58cq92//HxPZpmpOfWpny7b93yQf2lcW
N7WT/je/XBTa7DiD/j1fLIt92GPo33VTWex3PJYjf/PmothN33Mh/dnry9LtfW95OQNM7WR2dq4o
tNeb4citHymK3bT7GfT3froottn1BPrze8pip0+if/DrZbFbTykuKxiUV8157h+4oyx22yPqYvff
Wha7fTf9Oz9eFnvyk+gfuL0oFqDZdmpxfLPt1KproibdqvP0jc+XxT78nOqyrrrX3/OlsnQf9ui6
dCvKuqp+zH21LN2ZRxV/L8Lwu/Hum8tiTzyz7jt5/21lsdtPo393lsWeGFX3+tLzBMNzNT9bFjvd
q7z/VNxDar5XK/7uqv1e/cCmsoGTzzlypK68Kq6nmnNcVT8Kv89h+J1ecU3V3K+r/s6VluFwa0mS
JEmShkbqSY6IncBCt+ApwP3ALDDDoMH9xMy8KyK+A/gU8LTMLP+vVkmSJEnSUdjvOW4jNZIzcx9w
LkBEvAqYy8zLh8svB34TuHD475ttIEuSJEmSuqT2N8mLf4z9/wCfiohfAv4x8NLKfUuSJEmStK7G
NnFXZt4XEf8WuA740cy8f1z7liRJkiQto+nsJNITa9wD2J8F3A48bsz7lSRJkiRpzY2tkRwR3wM8
A/h+4JKIOGVc+5YkSZIkaT2MpZEcEQ3wJuBfZ+atwO8Arx/HviVJkiRJK2iayXx1WG0juT/89/8E
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
aokAAAAASUVORK5CYII=
"
/>

</div>
</div>
</div>

  </div>
</div>
<div class="cell border-box-sizing text_cell rendered">
  <div class="prompt input_prompt"></div>
  <div class="inner_cell">
    <div class="text_cell_render border-box-sizing rendered_html">
      <p>
        To understand what the percentage of flights for a particular (origin
        &rarr; destination) state pair that are delayed, we can look at a second
        metric using the same visualization. Here we compute the total number of
        flights for each (origin &rarr; destination) pair.
      </p>
    </div>
  </div>
</div>
<div class="cell border-box-sizing code_cell rendered">
  <div class="input">
    <div class="prompt input_prompt">In&nbsp;[40]:</div>
    <div class="inner_cell">
      <div class="input_area">
        <div class="highlight hl-ipython3">
          <pre><span></span><span class="n">trip_counts_df</span> <span class="o">=</span> <span class="n">df</span><span class="p">[[</span><span class="s1">&#39;ORIGIN_STATE_ABR&#39;</span><span class="p">,</span> <span class="s1">&#39;DEST_STATE_ABR&#39;</span><span class="p">,</span> <span class="s1">&#39;FL_DATE&#39;</span><span class="p">]]</span><span class="o">.</span><span class="n">groupby</span><span class="p">([</span><span class="s1">&#39;ORIGIN_STATE_ABR&#39;</span><span class="p">,</span> <span class="s1">&#39;DEST_STATE_ABR&#39;</span><span class="p">])</span><span class="o">.</span><span class="n">count</span><span class="p">()</span>
</pre>
        </div>
      </div>
    </div>
  </div>
</div>
<div class="cell border-box-sizing text_cell rendered">
  <div class="prompt input_prompt"></div>
  <div class="inner_cell">
    <div class="text_cell_render border-box-sizing rendered_html">
      <p>
        To put trip counts DataFrame and our earlier
        <code>delay_counts</code> DataFrame on the same axes, we rename the
        columns to <code>COUNTS</code> in both cases.
      </p>
    </div>
  </div>
</div>
<div class="cell border-box-sizing code_cell rendered">
  <div class="input">
    <div class="prompt input_prompt">In&nbsp;[41]:</div>
    <div class="inner_cell">
      <div class="input_area">
        <div class="highlight hl-ipython3">
          <pre><span></span><span class="n">delay_counts_df</span> <span class="o">=</span> <span class="n">delay_counts_df</span><span class="o">.</span><span class="n">rename_axis</span><span class="p">({</span><span class="s1">&#39;ARR_DEL15&#39;</span> <span class="p">:</span> <span class="s1">&#39;COUNTS&#39;</span><span class="p">},</span> <span class="n">axis</span><span class="o">=</span><span class="mi">1</span><span class="p">)</span>
<span class="n">trip_counts_df</span> <span class="o">=</span> <span class="n">trip_counts_df</span><span class="o">.</span><span class="n">rename_axis</span><span class="p">({</span><span class="s1">&#39;FL_DATE&#39;</span> <span class="p">:</span> <span class="s1">&#39;COUNTS&#39;</span><span class="p">},</span> <span class="n">axis</span><span class="o">=</span><span class="mi">1</span><span class="p">)</span>
</pre>
        </div>
      </div>
    </div>
  </div>
</div>
<div class="cell border-box-sizing text_cell rendered">
  <div class="prompt input_prompt"></div>
  <div class="inner_cell">
    <div class="text_cell_render border-box-sizing rendered_html">
      <p>
        Now we divide the delay counts by the total trip counts and perform the
        same transforms we did previous to produce the N by N matrix. In this
        case, each cell represents the proportion of flights between each
        (origin &rarr; destination) that were delayed.
      </p>
    </div>
  </div>
</div>
<div class="cell border-box-sizing code_cell rendered">
  <div class="input">
    <div class="prompt input_prompt">In&nbsp;[42]:</div>
    <div class="inner_cell">
      <div class="input_area">
        <div class="highlight hl-ipython3">
          <pre><span></span><span class="n">mat</span> <span class="o">=</span> <span class="p">(</span><span class="n">delay_counts_df</span> <span class="o">/</span> <span class="n">trip_counts_df</span><span class="p">)</span><span class="o">.</span><span class="n">unstack</span><span class="p">()</span><span class="o">.</span><span class="n">T</span><span class="o">.</span><span class="n">reset_index</span><span class="p">(</span><span class="n">level</span><span class="o">=</span><span class="mi">0</span><span class="p">,</span> <span class="n">drop</span><span class="o">=</span><span class="kc">True</span><span class="p">)</span><span class="o">.</span><span class="n">T</span>
</pre>
        </div>
      </div>
    </div>
  </div>
</div>
<div class="cell border-box-sizing text_cell rendered">
  <div class="prompt input_prompt"></div>
  <div class="inner_cell">
    <div class="text_cell_render border-box-sizing rendered_html">
      <p>
        In this second heatmap plot, the (CA &rarr; CA) and (TX &rarr; TX)
        hotspots from the firt visualization no longer stand out. Though there
        are many in-state delays for these two states, there are even more
        flights, keeping the percentage of delayed flights for these in-state
        trips lower than other routes.
      </p>
      <p>
        To the contrary, we see some cases where all flights from one state to
        another had arrival delays:
      </p>
      <ul>
        <li>(AR &rarr; UT)</li>
        <li>(MT &rarr; NY)</li>
        <li>(CO &rarr; RI) and (RI &rarr; CO)</li>
      </ul>
      <p>
        We can also see some other moderately hot spots, such as (AK &rarr; NJ)
        and (OK &rarr; MN), which seem to have a higher percentage of delays
        than other state pairs.
      </p>
      <p>
        One "crosshair" jumps out in the visualization: the row and column
        representing Illinois are nearly both filled with non-gray cells. On
        closer inspection, we see Illinois sends flights to and receives flights
        from every other state except one: TT, the state code abbreviation for
        U.S. Pacific Trust Territories and Possessions. And though it is
        difficult to make accurate relative value judgments from this
        visualization, it appears the run of cells in the row and column for
        Illinois are darker than most other row or column runs (e.g., GA).
      </p>
    </div>
  </div>
</div>
<div class="cell border-box-sizing code_cell rendered">
  <div class="input">
    <div class="prompt input_prompt">In&nbsp;[43]:</div>
    <div class="inner_cell">
      <div class="input_area">
        <div class="highlight hl-ipython3">
          <pre><span></span><span class="n">fig</span><span class="p">,</span> <span class="n">ax</span> <span class="o">=</span> <span class="n">plt</span><span class="o">.</span><span class="n">subplots</span><span class="p">(</span><span class="n">figsize</span><span class="o">=</span><span class="p">(</span><span class="mi">18</span><span class="p">,</span><span class="mi">18</span><span class="p">))</span>
<span class="n">asymmatplot</span><span class="p">(</span><span class="n">mat</span><span class="p">,</span> <span class="n">names</span><span class="o">=</span><span class="n">mat</span><span class="o">.</span><span class="n">columns</span><span class="p">,</span> <span class="n">ax</span><span class="o">=</span><span class="n">ax</span><span class="p">,</span> <span class="n">cmap</span><span class="o">=</span><span class="s1">&#39;OrRd&#39;</span><span class="p">,</span> <span class="n">cmap_range</span><span class="o">=</span><span class="p">(</span><span class="mf">0.</span><span class="p">,</span> <span class="mf">1.0</span><span class="p">))</span>
</pre>
        </div>
      </div>
    </div>
  </div>

  <div class="output_wrapper">
    <div class="output">
      <div class="output_area">
        <div class="prompt output_prompt">Out[43]:</div>

        <div class="output_text output_subarea output_execute_result">
          <pre>

&lt;matplotlib.axes.\_subplots.AxesSubplot at 0x7f679b051950&gt;</pre
          >

</div>
</div>

      <div class="output_area">
        <div class="prompt"></div>

        <div class="output_png output_subarea">
          <img
            src="data:image/png;base64,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
AAAAAADogEoatquabeswSc2/Nv+jpIPdNQIAAAAAdEjcTf+6WiVDkZ+RdFDrhSGECZLGSro7hCBJ
fSQtlOSfmhEAAAAAgA7qcGPazO6R1DeE8O9rgoQQNpN0nqQzzWxU+W+YpPVDCCOqX10AAAAAAP5b
pdexPUDSuSGEr0haKWmRpB0kHd/qeTMkHSrp7KwVBAAAAAC0LY8ZiLujihq2ZrZUTQ3W1T3vNHeN
AAAAAACoQB6/6wUAAAAAoGoqHYoMAAAAAOgm6KlswnYAAAAAANS0/Hts6/q4o4VFV/uCxZOkxY/7
skMnS8n7vqwkrVjuz767wh1tvOVWdzYeN00Fu8QXLp4mvTTLlx22g7TMfNn1t1c6/ylfdvQ+Kjx3
mS9b/KK0ZsbD6r333NH0ubtcuWjbTRSN39Rf7rN3+8rdbnPpBef+8ZE9pBfn+7KSFCQte9GXHeMv
VpLSV55w5aIBo6RF/+crdOhkaeVKX7YaVr7uz5ae9+VGSoUXf+fLFo9XOv9eVzQqjPeVWZYueM4X
HCdp+ZuZyla8pjua/sN5vh4nad6jvuzwXaU+/jrrrbf82bcz7NMZXbjuAFfurDTNVG7hhd/6gsUT
pddezlR2Jq+/4s++sciXGzpZeiPH1+yVZVtJUsZ9zCtZdKc7G298eBVrgjxFaU47YFmuhQMAAADo
nZJnf6d448NrflLhy6KoW7apjknTLt22uffYJnN/48rF445Q8vcLfdmPnqTk/y7wZbc5WYld68uG
qUoeOteX/dipSmZf4cuOP1rv/fgwV1aS1vzKdUoe+Kmv7O1Oy/Y+Pe3rOY03O0aNd33Pla3b7ZtK
/vZzX7kf/6KSJy92ZSUpnnh8tm398C982W2/oORB5745+dRsdb7/HF92+9OV/O8PXFlJinf5upJH
zvdlJ31eDQ2+0RfFYr2SeTf5yt3wwGznkAz7h/f1SuXXPPcaX9njpil57Fe+7FYnKnnCdzzGWxyf
6XMiy/7RePuZrmzd3t9Rcs8PXVlJinf+mpI5vpFQ8SZHqvGWb7qydft+T8lff+Qrd6evKpl9uS87
fnq2z6eM5/os+8hZke+74llpmu3cleVYzOF4ksr1zvKd71nfqI9448OVPH6RL7vlCZnep0zvsfOY
kMrHRYbvA5nq7Xyf0LPwG1sAAAAAQE2rqMc2hLCepHMlbS3pdUkvSzpVUh9J50taX02N5avNzNdd
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
g/54mi977CUadN/3fNlP/Vjpo746R7t8Xel9/+srd+zBSp+425ddf3sN+tPXfVlJOvJ8DfjVZ33Z
b/9BhbkX+7LF01V44bfO7IkqLL3emT1Ggx76sS+77/dUeDrDnGm7fF1qfN8dL8y5yBeccoYGXnms
L/vl6zIdT4XZF/qyO31VhafO82UladdvqPDcpb5s8UsqPPNLX3bHr6iw4NfOcj+v9K83+bKf3lGD
7v++L3vgjzTogR/4spJ0wA8zHcuDHvuZL7vnmRo040u+7HGXatBfvuXLTjtXg578hS+72zezvU+/
P8WXlaSTrlTUr587nul9euJcX3b3b/nPubt8XY33+Y7juizllssuLLvFly1Oy3TOzfL55v4uceT5
meqcVZbjMbnZt2/WHXl+pmOi8PINvmzxaA28/Bhf9qvXS6V/+rJlWfavARcd7ct+6wb1P+8oV/Rt
KV3ruzfV/DjemFmRJUlRmqarf1bnybVwAAAAAL3T2986UD2hYfv0xut3yzbVZs++1KXbNvce2+Qp
X49JvPmxarz0OFe27thL1HjjV3zZT/1Yyf/6ei7iXb6uxstP8JU7/SI13n6mL7v3d9R49eddWanp
fx3f+Z+DXNm+3/6DkvvOcWXjHU5X8tivfNmtTlTy9GW+7GbHqPGWb7qydft+z71/SE37SHLPD33Z
nb+mZObZvuyUM/TeTw5zZdf88nXZjqe//siVjXf6qpK7nT1bkuJdv6Hkb77/TY8//iUl9/r+Vzre
8StKHvH19MSTPq/G3/p65Oo+fZ4ab/qqL3vgj9Q442uurCTVHfDDTMdy45+/4yt3zzPVeIlvJELd
cZeq8ZpTfdlp56rxLl/vVN1u38z2Pl3oHF0jqe6kK93HVLzrN7K9T3/5ri+7+7eyfSbnUG5z2cnc
a3zZcdMynXOzfL55v0vUHXl+pjo3NCx3ZSWpWKzPdjxmec0Zjolk9hWubDz+aL33o0Nd2TW/er2S
B37qykpSvN1pmfavd757sCvb91s36O1vHejKomfJvWELAAAAAPBhVuQmmSePCiGsKP87MoQwK3uV
AAAAAADouGrMitwtx3QDAAAAAHoHhiIDAAAAQI2KmBVZEtexBQAAAADUOBq2AAAAAICaxlBkAAAA
AKhRzIrchB5bAAAAAEBNq0aPbctZkUMIYXGL+6ea2Y1VKAMAAAAAgDZlbtia2YDyv4sk9cm6PgAA
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
qW+lD0bFdbresfo2PiIqrh3vt8+OjC47z3d5/lbHRcd2yvyJx0THdrLeefYh3apv/MFRcSWgb/kt
42PXnhod2ymxx5rQ3duIDA+FSqWjExdr1mQREREREemEYTGGt/L0jUMypyqM231Q12/He2x7exdG
xZVKIxU7CLGdLDtvbPn2M6Niizser3U9zGM7WfayFtvJshXbHWUva7GdLHtZi+1k2ctabCfLzhsr
w4fOsRUREREREZGu1nKPrZn1ADcmd8cAi5L/c4EVktsvJ3+97j65PVUVERERERGRJQ2LEdW5tZzY
unsfMBHAzE4EFrr72f3Pm9mPgF+7+1Vtq6WIiIiIiIhIA+0YilyviUDNBiIiIiIiIjIoOj55lIiI
iIiIiEQqqE8RNHmUiIiIiIiIdDkltiIiIiIiItLVNBRZRERERESkWxXUVwnt6bGtZHxMRERERERE
pO1y9di6+8l1HjskzzJFREREREREWqGhyCIiIiIiIl1LsyKDJo8SERERERGRLqfEVkRERERERLpa
oVLp6DxPmmRKREREREQG3atfPYCVT72q68fxVp67fUjmVIW1dxzUddvxc2wXXXFCVNyIg86gfPNp
UbHFXb+SL/b2M+NidzyeRdeeFBU7Yq+TKM85N67cScdQvu/CqFiA4sTp9PYujIotlUZSvuM7ceVu
czTl++PqXdxyOosuODQqdsSnL831OcWuK0jWV55tc+ZZcbHbfyHf9nXL6XGxu3yZ8l3nxcV+4CjK
91wQFQtQ3OrTueqd6zsx79K4cjc/NN/nlGf7yLmu3zprWlTscl+YkWs/UH7sl3GxG3yURdefEhU7
YvLX820ft307Kra40xdZ9NsTo2IBRuxzMuXbzogs+wTKsyO3zW2Pyfc7kec3+eqvRsWO2P9Uyvf+
ICoWoPi+T1G+83txsR/8XM7tK/4zzvOdKM86O67c7Y7L/7uaZ/ua+8O42AmH5VrXeT7jThyzQbK+
8mxfPzkqKnbEJ87j1a8eEBUrw4uGIouIiIiIiEhXa6nH1sx6gBuTu2OARUAvMJKQJG/l7i+Z2erA
PcDO7v5UG+srIiIiIiIib1NfJbSY2Lp7HzARwMxOBBa6+9nJ/ROA04Hpyf8LldSKiIiIiIjIQMt7
jm31CcHnAPeY2THAtsBnci5bREREREREpKm2TR7l7m+Z2ReBa4E93H1Ru5YtIiIiIiIidRS6fmLn
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
aoVKpaNzPGmCKRERERER6YThMYb3tReHZk610uhBXb8dP8e2t3dhVFypNFKxgxDbybJLpZGUH/tl
VGxxg4927bpe9PuTo2JH7Hli173nTq/rTtW70ntfVGyhNFHrWrEDEtvJspe12E6WvazF9scvOu+T
UbEjjvpxrnovuuiIuHKPvLhr13W31btUGhkVJ+1hZnsC5wIjgEvc/Vt1XvNdYC/gX8An3b3hQZSG
IouIiIiIiMigMbMRwHnAnsCmwDQz26TmNXsDG7r7RsCRwAVpy0xNbM3sHDM7uur+dWZ2cdX9s8xs
kZltXBN3rpl9MeP7EhERERERkSiFIfqX6gPAo+7+pLu/CfwM2L/mNR8GfgLg7ncCo8xsrUYLbNZj
OxPYFsDMikAPIaPuty1wCzC1/4HkdQcCM5q9GxEREREREVnmjAWerrr/TPJYs9es02iBzc6xnQOc
k9zeDJgHjDGzUcCrwHuAnQhJ7DeT1+0I/NXdn0ZEREREREQGzko93TgJVtYJr2rfW8O41B5bd38O
eMvMxgGTCInuXcntrYEH3f1BoGxmWyRhU4HLMlZUREREREREli3PAuOq7o8j9MimvWad5LG6skwe
NZsw5HhbQmI7J7k9CZiVvGYGMDU5CXh/4IoMyxUREREREZFlz93ARmY23sxWAKYA19S85hrgYAAz
2wZY4O5/a7TALIntLGA7YAIwF7iDxYnu7OQ1PwM+BuxO6MXtzfqOREREREREZNnh7m8BRwHXAQ8B
l7v7w2Y23cymJ6/5HfC4mT0KXAh8Jm2ZWa5jOxs4gTBrVQV4KTnHdlPg8KTQx83sReB0wrWIRERE
REREROpy92uBa2seu7Dm/lFZl5elx3YeYTbkO6oee5DQFTy/6rEZgAFXZS1cREREREREJK+mPbbu
vghYreaxQ+q87jvAd9pXNREREREREZHmsvTYioiIiIiIiAxZSmxFRERERESkqymxFRERERERka5W
qFQqnSy/o4WLiIiIiMiyqfKvFyisMqbQ6XpIe2S53M+A6u1dGBVXKo3sylhe64uKZaUeyo//Oiq0
+O79ousMnV1fld77omILpYldt330x1devD8qtjB6y657z51e191W71JpJOUX7mj+wjqKY7bRulbs
kCx7WYvtZNnLWmx/fPm2M6JiizudQGWBR8UWRlnXra9u3q4r/3ohKlaGFw1FFhERERERka7WNLE1
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
482BbwAAAABJRU5ErkJggg==
"
/>

</div>
</div>
</div>

  </div>
</div>
<div class="cell border-box-sizing text_cell rendered">
  <div class="prompt input_prompt"></div>
  <div class="inner_cell">
    <div class="text_cell_render border-box-sizing rendered_html">
      <p>
        Of course, this plot only shows proportions of delayed flights between
        two states and doesn't depict the number of flights between the two nor
        the magnitude of the delay. So while all flights between Rhode Island
        and Colorado were delayed, we need to keep in mind ...
      </p>
    </div>
  </div>
</div>
<div class="cell border-box-sizing code_cell rendered">
  <div class="input">
    <div class="prompt input_prompt">In&nbsp;[44]:</div>
    <div class="inner_cell">
      <div class="input_area">
        <div class="highlight hl-ipython3">
          <pre><span></span><span class="nb">print</span> <span class="n">delay_counts_df</span><span class="o">.</span><span class="n">loc</span><span class="p">[</span><span class="s1">&#39;RI&#39;</span><span class="p">,</span> <span class="s1">&#39;CO&#39;</span><span class="p">]</span>
<span class="nb">print</span> <span class="n">trip_counts_df</span><span class="o">.</span><span class="n">loc</span><span class="p">[</span><span class="s1">&#39;RI&#39;</span><span class="p">,</span> <span class="s1">&#39;CO&#39;</span><span class="p">]</span>
</pre>
        </div>
      </div>
    </div>
  </div>

  <div class="output_wrapper">
    <div class="output">
      <div class="output_area">
        <div class="prompt"></div>

        <div class="output_subarea output_stream output_stdout output_text">
          <pre>

COUNTS 3
Name: (RI, CO), dtype: float64
COUNTS 3
Name: (RI, CO), dtype: int64

</pre
          >
        </div>
      </div>
    </div>
  </div>
</div>
<div class="cell border-box-sizing text_cell rendered">
  <div class="prompt input_prompt"></div>
  <div class="inner_cell">
    <div class="text_cell_render border-box-sizing rendered_html">
      <p>there were only three of them!</p>
      <p>
        A visualization that captures both the proportion of (origin &rarr;
        destination) flights delayed as well as the proportion of total flights
        represented by that state pair is yet another exercise for the future.
      </p>
    </div>
  </div>
</div>
<div class="cell border-box-sizing text_cell rendered">
  <div class="prompt input_prompt"></div>
  <div class="inner_cell">
    <div class="text_cell_render border-box-sizing rendered_html">
      <h2 id="Delay-Distribution-by-Date">
        Delay Distribution by Date<a
          class="anchor-link"
          href="#Delay-Distribution-by-Date"
          >&#182;</a
        >
      </h2>
      <blockquote>
        <p>How did arrival delay in minutes vary day-by-day?</p>
      </blockquote>
      <p>
        To address this question, we can group the
        <code>ARR_DELAY_NEW</code> column by date and look at their descriptive
        stats. A Tukey box plot by day is a reasonable way for us to start.
      </p>
    </div>
  </div>
</div>
<div class="cell border-box-sizing code_cell rendered">
  <div class="input">
    <div class="prompt input_prompt">In&nbsp;[45]:</div>
    <div class="inner_cell">
      <div class="input_area">
        <div class="highlight hl-ipython3">
          <pre><span></span><span class="n">fig</span><span class="p">,</span> <span class="n">ax</span> <span class="o">=</span> <span class="n">plt</span><span class="o">.</span><span class="n">subplots</span><span class="p">(</span><span class="n">figsize</span><span class="o">=</span><span class="p">(</span><span class="mi">18</span><span class="p">,</span><span class="mi">10</span><span class="p">))</span>
<span class="n">sns</span><span class="o">.</span><span class="n">boxplot</span><span class="p">(</span><span class="n">df</span><span class="o">.</span><span class="n">ARR_DELAY_NEW</span><span class="p">,</span> <span class="n">df</span><span class="o">.</span><span class="n">FL_DATE</span><span class="p">,</span> <span class="n">ax</span><span class="o">=</span><span class="n">ax</span><span class="p">)</span>
<span class="n">fig</span><span class="o">.</span><span class="n">autofmt_xdate</span><span class="p">()</span>
</pre>
        </div>
      </div>
    </div>
  </div>

  <div class="output_wrapper">
    <div class="output">
      <div class="output_area">
        <div class="prompt"></div>

        <div class="output_png output_subarea">
          <img
            src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAABCkAAAJHCAYAAAC92Ax3AAAABHNCSVQICAgIfAhkiAAAAAlwSFlz

AAALEgAACxIB0t1+/AAAIABJREFUeJzs3X+UnNV54PlviUYSSCpCQptA48ReW1yH2M4QY4P24JBk
vTEjbPDZzCLAsbHxmZkzrAfHwcRggxwEzi8bk/HZsXfnZGziSSSazOZ42I0DON7Y8SYRwjGO7ZC9
hGSYCGFArEV1Sxj9QLV/vFWqVtNdLXV31X2q6vs5h8Pb1SXV1Vv3ve99n/vce2vNZhNJkiRJkqTS
VpQugCRJkiRJEhikkCRJkiRJQRikkCRJkiRJIRikkCRJkiRJIRikkCRJkiRJIRikkCRJkiRJIYz1
8i9PKX0OuAR4Juf8utZrbwL+V+BE4BBwbc75odbvbgKuAV4Erss5P9B6/Q3AXcBq4Es55w/0styS
JEmSJKn/ep1J8Xng4lmv/TZwS875XGBz62dSSucAm4BzWn/mMymlWuvPfBZ4X855PbA+pTT775Qk
SZIkSQOup0GKnPPXgT2zXv4ecErr+IeAXa3jy4BtOeeDOefHgceA81NKZwDrcs47Wu/7AvCOXpZb
kiRJkiT1X0+ne8zjRuD/SSl9kipIsqH1+pnA9hnvewKYAA62jtt2tV6XJEmSJElDpMTCmf+Rar2J
HwM+CHyuQBkkSZIkSVIwJTIp3pRzfkvr+D8Dv9s63gW8fMb7zqLKoNjVOp75+i4WcOjQi82xsROW
XlpJkiQtm+eeg5Sq40cfhVNO6f5+SdJQqs33ixJBisdSShflnL8G/DzwaOv1e4GtKaVPUU3nWA/s
yDk3U0pTKaXzgR3Au4BPL/Qhe/Y835vSS5IkadGmpuDw4TUAPPvsPg4cKFwgSVLfjY+vm/d3vd6C
dBtwEXBaSmkn1W4e/wr49ymlVcAPWj+Tc34kpXQP8AidrUmbrb/qWqotSE+i2oL0vl6WW5IkSb1R
r8PmzfuPHEuSNFOt2Wwu/K4BtHv39HD+wyRJkgZcu/tZmzfZV5I0zMbH14Wa7iFJkqQRZnBCkjSf
Ert7SJIkSZIkvYRBCkmSJEmSFIJBCkmSJEmSFIJBCkmSJEmSFIJBCkmSJEmSFIJBCkmSJEmSFIJB
CkmSJEmSFIJBCkmSJI2kZrP6T5IUh0EKSZIkjaTJyTEmJ8dKF0OSNEOtOaTh4927p4fzHyZJkqQl
azRgw4Y1AGzfvo96vXCBJGmEjI+vq833OzMpJEmSNHJq83aPJUklmd8mSZKkkVOvw+bN+48cS5Ji
cLqHJEmSRlK7G2xWhST1V7fpHmZSSJIkaSQZnJCkeFyTQpIkSZIkhWCQQpIkSZIkhWCQQpIkSZIk
hWCQQpIkSZIkhWCQQpIkSZIkhWCQQpIkSZIkhWCQQpIkSZIkhWCQQpIkSZIkhWCQQpIkSZIkhWCQ
QpIkSZIkhWCQQpIkSZIkhWCQQpIkSZIkhWCQQpIkSZIkhWCQQpIkSZIkhWCQQpIkSZIkhWCQQpIk
SZIkhWCQQpIkSZIkhWCQQpIkSZIkhWCQQpIkSZIkhWCQQpIkSZIkhWCQQpIkSZIkhWCQQpIkSZIk
hWCQQpIkSZIkhWCQQpIkSZIkhWCQQpIkSZIkhWCQQpIkSZIkhWCQQpIkSZIkhWCQQpIkSZIkhWCQ
QpIkSZIkhWCQQpIkSZIkhWCQQpIkSZIkhWCQQpIkSZIkhTDWy788pfQ54BLgmZzz62a8/m+Ba4EX
gT/OOX+49fpNwDWt16/LOT/Qev0NwF3AauBLOecP9LLckiRJkiSp/3qdSfF54OKZL6SUfg64FHh9
zvm1wCdbr58DbALOaf2Zz6SUaq0/9lngfTnn9cD6lNJRf6ckSZIkSRp8PQ1S5Jy/DuyZ9fK/AX4j
53yw9Z7drdcvA7blnA/mnB8HHgPOTymdAazLOe9ove8LwDt6WW5JkiRJktR/JdakWA/8TEppe0rp
qyml81qvnwk8MeN9TwATc7y+q/W6JEmSJEkaIiWCFGPAqTnnC4AbgHsKlEGSJEmSJAXT04Uz5/EE
8EcAOeeHUkqHU0qnUWVIvHzG+85qvXdX63jm67sW+pBTTz2ZsbETlq3QkiRJkiSpt0oEKb4I/Dzw
tZTS2cDKnPOzKaV7ga0ppU9RTedYD+zIOTdTSlMppfOBHcC7gE8v9CF79jzfu3+BJEmSJElalPHx
dfP+rtdbkG4DLgJ+JKW0E9gMfA74XErpO8AB4N0AOedHUkr3AI8Ah4Brc87N1l91LdUWpCdRbUF6
Xy/LLUmSJEmS+q/WbDYXftcA2r17ejj/YZIkSZIkDbDx8XW1+X5XYuFMSZIkjbBms/pPkqTZDFJI
kiSpryYnx5icLLE0miQpOqd7SJIkqW8aDdiwYQ0A27fvo14vXCBJUt853UOSJEkh1ObtlkqSVGYL
UkmSJI2oeh02b95/5FiSpJmc7iFJkqS+anc/zaqQpNHUbbqHmRSSJEnqK4MTkqT5uCaFJEmSJEkK
wSCFJEmSJEkKwSCFJEmSJEkKwSCFJEmSJEkKwSCFJEmSJEkKwSCFJEmSJEkKwSCFJEmSJEkKwSCF
JEmSJEkKwSCFJEmSJEkKwSCFJEmSJEkKwSCFJEmSJEkKwSCFJEmSJEkKwSCFJEmSJEkKwSCFJEmS
JEkKwSCFJEmSJEkKwSCFJEmSJEkKwSCFJEmSJEkKwSCFJEmSJEkKwSCFJEmSJEkKwSCFJEmSJEkK
wSCFJEmSJEkKwSCFJEmSJEkKwSCFJEmSJEkKwSCFJEmSJEkKwSCFJEmSJEkKwSCFJEmSJEkKwSCF
JEmSJEkKwSCFJEmSJEkKwSCFJEmSJEkKwSCFJEmSJEkKwSCFJEmSJEkKwSCFJEmSJEkKwSCFJEmS
JEkKwSCFJEmSJEkKwSCFJEmSJEkKwSCFJEmSJEkKwSCFJEmSJEkKwSCFJEmSJEkKwSCFJEmSJEkK
wSCFJEmSJEkKYayXf3lK6XPAJcAzOefXzfrd9cAngNNyzt9vvXYTcA3wInBdzvmB1utvAO4CVgNf
yjl/oJflliRJkiRJ/dfrTIrPAxfPfjGl9HLgfwT+24zXzgE2Aee0/sxnUkq11q8/C7wv57weWJ9S
esnfKUmSJEmSBltPgxQ5568De+b41aeAX5312mXAtpzzwZzz48BjwPkppTOAdTnnHa33fQF4R4+K
LEmSJEmSCun7mhQppcuAJ3LO3571qzOBJ2b8/AQwMcfru1qvS5IkSZKkIdLTNSlmSymdDHyEaqpH
W22et0uSJEmSpBHS1yAF8CrgFcDfpJQAzgL+OqV0PlWGxMtnvPcsqgyKXa3jma/vWuiDTj31ZMbG
TlieUkuSJEmSpJ7ra5Ai5/wd4PT2zyml/wq8Ief8/ZTSvcDWlNKnqKZzrAd25JybKaWpViBjB/Au
4NMLfdaePc/35N8gSZIkSZIWb3x83by/6+maFCmlbcBfAmenlHamlN476y3N9kHO+RHgHuAR4E+A
a3PO7d9fC/wu8PfAYznn+3pZbkmSJEmS1H+1ZrO58LsG0O7d08P5D5MkSZIkaYCNj6+bd23Kvu/u
IUmSJEmSNBeDFJIkSZIkKQSDFJIkSZIkKQSDFJIkSZIkKQSDFJIkSZIkKQSDFJIkSZIkKQSDFJIk
SZIkKQSDFJIkSZIkKQSDFJIkSZIkKQSDFJIkSZIkKQSDFJIkSZIkKQSDFJIkSZIkKQSDFJIkSSOk
2az+kyQpIoMUkiRJI2RycozJybHSxZAkaU615pCG0nfvnh7Of5gkSdIiNRqwYcMaALZv30e9XrhA
kqSRND6+rjbf78ykkCRJGhG1ebuEkiTFYK6fJElSH7STV0sGCup12Lx5/5FjSZKicbpHYBE6M5Ik
aXncfXc1NnTFFYeKlsP+hSSptG7TPQxSBBalMyNJkpbGtSAkSeroFqRwukdQjQZs2bIKgI0bD9mZ
kSRpgJm1IEnSsTFIEZSdGUmShodrQUiSdGyc7hGY0z0kSRoergUhSVLFNSkGlJ0ZSZIkSdKwcU2K
AWVwQpIkSZI0SlaULoAkSZIkSRIYpJAkSZIkSUEYpJAkSZJGXLPZWQ9NkkoySCFJkiSNuMnJMSYn
Xa5OUnnu7iFJkiSNsEYDNmxYA8D27fuo1wsXSNLQ67a7h5kUkiRJ0ghzRzlJkZjTJUmSJI2weh02
b95/5FiSSnK6hyRJkjTi2o8EZlVI6odu0z3MpJAkSZJGnMEJSVG4JoUkSZIkSQrBIIUkSZIkSQrB
IIUkSZIkSQrBIIUkSZIkSQrBIIUkSZIkSQrBIIUkDYFms7N9nCRJkjSoDFJI0hCYnBxjctJdpSVJ
kjTYas0hHXrbvXt6OP9hkjRLowEbNqwBYPv2fdTrhQskSZIkdTE+vq423+/MpJCkAVebt4mXJEmS
Bou5wZI04Op12Lx5/5FjSZIkaVA53UOShkC7KTerQpIkSdF1m+5hJoUkDQGDE5IkSRoGrkkhSZIk
STqK25urFIMUkiRJkqSjuL25SunpmhQppc8BlwDP5Jxf13rtE8DbgAPAPwDvzTk3Wr+7CbgGeBG4
Luf8QOv1NwB3AauBL+WcP7DQZ7smhSRJkiQdP7c3V6+V3IL088DFs157APjJnPNPAY8CNwGklM4B
NgHntP7MZ1JK7YJ/Fnhfznk9sD6lNPvvlCRJkiQtA9e6Ukk9zd/JOX89pfSKWa99ecaPDwK/2Dq+
DNiWcz4IPJ5Segw4P6X034B1Oecdrfd9AXgHcF8vyy5Jg8TdPSRJ0nJxe3OVVHqS0TXAttbxmcD2
Gb97ApgADraO23a1XpcktbTnjF5xxaHCJZEkScNg0yb7FCqjWJAipfRR4EDOeWupMkjSMGg0YMuW
VQBs3HjIEQ9JkrRkZmeqlCJBipTSe4CNwP8w4+VdwMtn/HwWVQbFrtbxzNd3LfQZp556MmNjJyy5
rJIU3cqVsKK1wtBpp63jlFPKlkeSJElarL4HKVqLXt4AXJRzfmHGr+4FtqaUPkU1nWM9sCPn3Ewp
TaWUzgd2AO8CPr3Q5+zZ8/zyF16Sgrr55qo5P3DgELt3Fy6MJC3AdXQkabSNj6+b93e93oJ0G3AR
cBrwNPAxqt08VgLfb73tr3LO17be/xGqdSoOAR/IOd/fer29BelJVFuQXrfQZ7sFqaRRYodf0iC5
+27X0ZGkUdZtC9KeBilKMkghSZIUT6MBGzasAWD79n2uoyNJI6hbkGJFPwsiSZKk0WbGlySpm9Jb
kEqSJGmE1OuwefP+I8eSJM3kdA9JkiT1levoSPF5naqXnO4hSZKkMGo1H3yk6CYnx5icNPE+kmaz
EzwaZmZSSJIkSZKOcIHbmIZpZ6RumRSGxiRJkiRJR5jpFE+jAVu2rAJg48ZDQx04MkghSZIkSTrC
BW7jGaXAkdM9JEmSRoiL4Uk6FrYV8YzKdA+DFJIkSSNkmDq5ktQPUQI2UcqxHAxSSJIkycXwJGkR
DO4uPxfOlCRJ0lCMvklSP43SgpVRGKSQJEkaES6GJ0nHx+Bu/zndQ5IkaYQM05xmSeoHp3ssP9ek
kCRJkiRpEQzuLj/XpJAkSZIkaREMTvTXitIFkI5Fs9mJYEqSJEmShpNBCg2EyckxJidN/JEkSZKk
YeaaFArPPd0lSZIkaXh0W5PCTAqF5xwwSZIkSRoN5s8rPPd0lyRp+bhKvSQpMqd7aCDYoZIkaXnc
fXc1RnXFFYcKl0SSNKq6TfcwSCFJkjQiGg244IJqnacHH3SdJ0lSGd2CFE73kCRJGhG1GuzfX7oU
kiTNzyCFJGmoOD1Mml+zCTUvDklSYAYpJElDZXLS+fbSfGo1WLXKGbGSpLhck0KSNDQaDdiwoZpv
v3278+2lubhwpiSpNNekkKQecWpBR4Rz4fcgLWzTJoMTkqS4DFJI0hI4taAjwrmo12Hz5v1HjiW9
lME8SVJkTveQpEVyakFHpHMRIaMjQhl0NL8TSZLi6DbdY0U/CyJJw8SHnY5I56JWK1+eycmxI5kl
isHvpKPZ7ARtJEmKxkwKSVoCF6Dr8FxUImWVqOJ3cjSvVUlSaS6cKUk94gJ0HZ6LSq3mKHU0pTNr
Imk0YMuWVQBs3Hho5AM2kqR4DFJIOm7O7e7wHHR4Lir1Olx88aEjxyrPBVU7vE4lSdEZpJB03CLs
4iBF1WjA/fdX18jU1P6RfyiOwkyfSr0Ot9yyn1rNgI0kKSaDFJKOi6nCUneOVMfk93I0pyRJkqLq
GqRIKX0B+DPgz3LOj/elRJJCs6MvdefUAkXWaMBtt1WB5ksuMdAsSYpnoUyKbwO/CHwqpdSgClh8
lSpo8U89LpukgHwAkxbm1AJFZaBZkhTdMW1BmlI6ATgXuAj4WeBCYE/O+b/raemWwC1Ipd5x4UxJ
GlxuQSpJKm3JW5DmnF9MKT0P/AB4AXgOeGx5iidp0BickKTBZaaPJCmyhdakuJYqc+KngL8HvgZ8
EvjrnLN3OEmSpAFjoFmSFNlCmRSfBh4CbgX+75zzU70vkiRJkiRJGkULBSl+hGr9iZ8BrksprQX+
gmoBza/lnL/X4/JJkiRJkqQRcUwLZ7a1ghS/CHwEeHXO+YReFWypXDhzebhAoiRJkiRpOS1p4cyU
0jjwc1RrU/ws8ApgB7B1WUqn0CYnXQFckiRJktQfXTMpUkqPAK+kWpfiz4CvAn+Vc36hL6VbAjMp
lq7RgA0b1gCwffs+6vXCBZIkSZIkDbylZFJcB/xFzvkHy1skDQKneEiSJEmS+mnFAr8/pR2gSCm9
fuYvUkr/qmelKqzZ7KzFMMrqddi8eT+bN+83i0KSJEmS1HMLZVLcDPwfrePfA86d8bt/A/yHbn84
pfQ54BLgmZzz61qv/TAwCfw48Dhwec75udbvbgKuAV4Erss5P9B6/Q3AXcBq4Es55w8c2z9vcVyH
oWPTJs+BJEmSJKk/FsqkWKrPAxfPeu1G4Ms557OBr7R+JqV0DrAJOKf1Zz6TUmpPOPgs8L6c83pg
fUpp9t+5bBoN2LJlFVu2rGJqqlefMjhqNad9SJIkSZL6o6dBipzz14E9s16+lCorg9b/39E6vgzY
lnM+mHN+HHgMOD+ldAawLue8o/W+L8z4M8vOB3JJkqTecmqtJGk+C033OC2ldC1Qm3FM++dFfubp
OeenW8dPA6e3js8Ets943xPABHCwddy2q/V6T7TXYWgfS5IkaXk5tVaSBlM7wNzLwf2FghRfAd44
xzHAny71w3POzZRSuDi66zBI0vHrx01L0uBrT60F2LjxkINCkjRA+hFk7hqkyDm/pwef+XRK6Udz
zk+1pnI803p9F/DyGe87iyqDYlfreObruxb6kFNPPZmxsROWqciSpIXcdVcVoLj66tIlkRTZypWw
ojXh+LTT1nHKKWXLI0k6Ns89B7ffXh2/+930rP3uGqRoLWY5r5zzI4v4zHuBq4Hfav3/izNe35pS
+hTVdI71wI5WtsVUSul8YAfwLuDTC33Inj3PL6JokqTFaDTghhvWAHDhhfscGZXU1c03V13QAwcO
sXt34cJIko7J1BQcPlz19559dh8HDiz+7xofXzfv7xaa7vElYK7pGOuAU4GuqQoppW3ARVTrWewE
NgO/CdyTUnofrS1IoQp4pJTuAR4BDgHX5pzbn30t1RakJ1FtQXrfAuWWJPWRUzwkHQ+n1krS4OnX
+o215nEsrZxSWgNcD/wvwBdyzjf0qmBLtXv3dLi1LiRpmN19twvhSZIGn2ssSfNbrutjfHzdvH/D
QpkUAKSUxqiyGT5MlV3x0znnBdeFkCSNDkdGJUnDwN1npPn1I3i30JoUNao1ID4G/DXwcznnR3tf
LEnSoHHESZI06Nx9RipvoUyKbwNrgFuBbwBjMxfTXOTCmZIk9czhw9X/27sHSDqaqezS/LwupPIW
ClKso1o489fm+f0rl7U0kqSBFeXB5/rrqxGwO+/cX7YgUlCmskvz69fCgJLmd1wLZ84npXRazvnZ
ZSjPsnHhTEnqrwgLZ+7cCeedtxaAb35zLxMTxYoihdRowIYN1fZx27eX2y44SlBTmov1U+q9JS+c
eQy+DJy7TH+XJGnARJnD6xQPqbsoD11mc3T4QByP34VU1nIFKSRJIyxKh25iAq666uCRY0lHi5DK
HiWoGYUBG0k6mkEKSdKSRXjwabvjDteikLopvV1wlKBmBAZsJOmlDFJIkpZF6QefNqd8SN2VDhJE
CmqWVvq7kDRYRmV6mEEKSdKyGPYb5vEYlU6EtFhRgpqlGbCRdDxGZXpY1yBFSul1OefvHMPf80fL
VB5JkgbeqHQipMUygNdhwEbSsRil6WFdtyBNKf0T8L8Bv5lzPty3Ui0DtyCVJJXQaMAFF1RbPD74
YLktHiVJ0vCYmur0L0puIb1cum1ButDM3XOB1wF/lVJ6zbKWSpKkIVSrwf791X+SJEnLoT09bPPm
/QMfoFhI10yKtpTSO6gyKv4CaGdUNHPOl/ewbEtiJoUkqYRGA376p9cC8PDDe4e+IyFJkvpjmNa8
6pZJseDCmSmlOnAp8BTwx8wIUixL6SRJGiK1Gqxa5S1SkiQtr2EIThyLhRbOvBj4LPD7wL/OOR/s
S6kkSRpQrtYvSZK0eAstnPld4D0552/Mev0k4F/knP9Tj8u3aE73kCSVMkzpmJIkScttKdM93pBz
PrL0V0rpAuAa4H8GvgmEDVJIklSKwQlJkqTFWXDhzJTSy4B3A++l2g3kZcDrcs5P9r54i2cmhSRJ
kiRJ8Sx6C9KU0heBbwGvAN6bc/4JYCp6gEKSJEmSJA2erkEK4I1ABv4S+HbviyNJkiRJkkbVQkGK
HwM+Cfwi8ERK6fPA6p6XSpIkST3RbHYWd5UkKZoF16RoSymdBryLam2KU4CtOeebeli2JXFNCkmS
pJe6++5q3fQrrjhUuCSSpOMxTLuHdVuT4piDFDOllN5ItUbFtUspWC8ZpJAkSTpaowEbNqwBYPv2
fdTrhQukoXrokNRbwxRkXvTCmfPJOT8ErF90iSRJktR3PgjHMzk5xuTkWOliSAqu0YAtW1axZcsq
pqZKl6a3ltIivmbZSiFJkqSeq9dh8+b9R45VVvuhA2DjxkN+J5LmNUpBZsO2kiRJI2TTpvJpwk5x
qIz6v1/SsYsSZO5H+22QQpIkDT0fijsinIP2vOorrywfMCkpykNHFF6nUncRgszt6Wm9XBej68KZ
KaXdXf7sqTnnsEEOF86UJEltw7TY2KBrNODcc6vFO7/1LRfv9MG8w+tUim05F1/utnDmQkGGNy7+
YyVJkspz3n8s09Owd2/tyPGofx8GJypep0czeKWI+lUfuwYpcs6P96cYkiRJvWEnP5Z6HVavro7X
rStbFsXhdXq0fqTUS8erX1PUugYpUkoP5Jx/oXX8mZzztTN+982c80/3rmiSJA0mR8Bicd5/LM0m
jI15fehoXqcdZpUosn6si7HQdI/xGccbZv3OW4skSXNwBCyeCIuNqVKrwerVLh2ml/I6rRjAU2T9
qJ9hF76UJGkQOQIWk53+OBwx13yiXKels+G8RjTqDFJIkrSMonSypcgcMVdkEbLhvEY0yhbagvQQ
sKf14w8Bz8349Q/lnE/sYdmWxC1INaxKR/clLcxt9CRpMC3nFouDzj6nemkpW5C+epnLImmJIkT3
pbnYmelwBEySBpP3sA77nCqlaybFTCml0wByzs/2tETLxEwKDSOj+4osSvaAwRJJ0lJEuZ+VZJ9T
vbaUTApSSh8EPgy8rPXz08Bv5Zx/Z9lKKOmY+NClqCItFhlh5MdAiSQNrgjZcKXvI96/VFLXIEVK
6ZeAfw1cDeyg2nb0jcCdKaVnc86/3/siSmpztWdFFaUzEyVYEiFQIklanAj3tNL3EfucKmmhhTO/
Drw/5/w3s15/PfDvc85v7nH5Fs3pHhpWpSPr0nwipMdOTcEFF5RNTzVFVpK0FFHuI/Y51UtLme5x
+uwABUDO+dsppZctuWSSjps3CkUVIT02wsiP16jmY4df0rGI0kZEKYdGz0JBir1dfvf8chZEkjTY
onRmSgdLIgRKFFPp9G3FZPBKs3kf0ahbaLrHTuA3qNaiaGu2fr4x5/zy3hZv8ZzuIUmjKUKHP0IZ
FEuU9G3FE2GqHNhuReP3oWG3lOkeX6FaKHMuf7roEklaNG9aUncRRqu9PjWbdUJzibLYL8RoOyXF
149nka6ZFMcqpXRxzvm+ZSjPsjGTQsMqyoiLFJGj1YosSvttsDuOCIv9gm1nRFHaC2m25aqbS8mk
OFa/AYQKUkjDKNKIixSRD12KrPR6KW2OmMcRZe0B285YovT3DGjGU/o76VfdXK4gxXFLKd0E/BJw
GPgO8F5gDTAJ/DjwOHB5zvm5Ge+/BngRuC7n/ECBYktFeZOQuovS4ZfmEqEN9+EnngjBK9vOWKJc
FwY04yn9nfSrbhYJUqSUXgH8S+Ancs77U0qTwBXATwJfzjn/dkrpw8CNwI0ppXOATcA5wATwpyml
s3POh0uUXyrFToS0sAgdfikqH37iifKd2HbGEaG/FyWgqY4I30m/6mapTIop4CBwckrpReBk4Eng
JuCi1nt+D/gqVaDiMmBbzvkg8HhK6THgTcD2PpdbKs5OhNRdlA6/FJEPP5qPbWcspft71od4onwn
/aibRYIUOefvp5TuAP4J+AFwf875yyml03POT7fe9jRweuv4TI4OSDxBlVEhjZwoDZQUlWnkUnc+
/Ejxlb5OIgQ0dbQo30k/6uaigxQppXNyzo+0fvzocf7ZVwG/DLwCaAB/mFL6pZnvyTk3U0rdduhw
9w5JavHBvMM0cqm70u1EvQ633FK+oy2pu9IBTb3UqHwnCwYpUkqvBxLw7ZxzTin9KPBx4G20Mh1y
zl86zs89D/jLnPP/1/qMPwI2AE+llH405/xUSukM4JnW+3cBL5/x589qvTavU089mbGxE46zWJrN
Bx9pMNx1V3WdXn116ZKU9dxzcPvt1fG73w2nnFK2PJLmtm5d1WaNj5cuiSTpePTj+bBrkCKl9EHg
FuBR4DWab0kIAAAgAElEQVQppduA64HfB85ewuf+v8AtKaWTgBeAtwA7gH3A1cBvtf7/xdb77wW2
ppQ+RTXNY33r/fPas+f5JRRPbe7RLMXXaMANN1T721944Wjvbz81BYcPV+fi2Wf3ceBA4QJJeolG
A371V6vr9M1vHu02S5IGzXI9H46Pr5v3dwtlUvxL4JxWZkMC/hb4mZzzXy6lQDnnv0kpfQH4BtUW
pN8E/gOwDrgnpfQ+WluQtt7/SErpHuAR4BBwbc7Z6R495sJW0mAw06kjynxNSfOzzZKkwdSv58Na
szn/s35K6eGc87kzfv5uzvm1vSnK8tq9e9ogxhJNTcEFF1QjHdu3O9IhRWbWU4fT1KT4bLMkafAs
5/Ph+Pi6eXtqCwUp/gH4t+33Ap9u/VwDmotYi6JvlhKksIPbYSdCGgy2W5qL9UJRWTclaTAt43SP
RQcpvsrRu2jUZv6cc/65JZWsh5YSpPDBvMNOhCQNLu9nisr+haRBYpvVsVznYtFBikG22CBFo9FJ
YXnwwbJTHLwYJEmL1WjAhg1O2VNMBtAkDRLbrOXXLUix4Bakc0kpnQLclHO+cdGlCqpWg/37S5ei
cvfdY9RqXgySpONngFtRuTC3onOgUDPZZvXfQluQ/jDwUeAngIeBW4H3ALcB/1evC1dCswm1AC1S
owE337wagI0b93oxSJKOizudKKoA3Sypq8lJR83VYZvVfwtlUvwusB/4P4GNwF8CB4C35Jy/0+Oy
FVGrwapV5afATE/D3r2dYzuYUkyOtmguUerFpk12sBWPATRF5qh5R5R7WWm2Wf23UJDi7PaWoyml
/wg8A5yVc97b85IVEqUS1uuwZk3VMqxbV64ckrpztEVziVIvRr1jqbgMoCkq282OKPeyCKK0WaMS
OFpod4+Hc87nzvdzZMOwBem2bVXDcOWVMS4KSUdzYULNxXohSYPNRRK9l0U1THVzKQtnvjKldA/V
1qMAr0gp/WHruJlzvnw5ChhN6eBE2zBUPmmYRWkrFIv1IqYoAxAReC6k7iKMmpe+Tm0f4hmlqUgL
BSl+GWjSCVL8cetngB/vVaFUsXGQYosyPUyxWC9iMm25w3MhdRehD176OvVeFk+EetkvXad7zJZS
OpNqd4/3ACtyzq/uTbGWbinTPSTpWJUe6VBM1otYTFvu8FxI8UW5Tr2XxeN0j5aU0onAZcA1wJuA
E4G35py3L1sJg/GClHSsbCc0F+tFLH4fHZ4LKb4o12mUcqgjwlSkfugapEgp/Q6wCfhr4C7gfwL+
bpgDFFA+vUqSJC0f05Y7PBdSfF6nms+oBI4W2t3jB8D9wCdyzn/Reu2/5pxf2afyLdpip3tESa+S
JEnLxyzJDs+FFJ/XqYbdUqZ7nAlcBfy7lNIpwO8fw58ZaDYEkgaRnRmpO6+NDs+FJCmyY144M6X0
euB9VEGLvwP+IOf8v/ewbEuylIUzh2lBEkmjwXZLis9goqRj5X1dw65bJsVx7e4BkFJaSbWQ5ntz
zhuXWLaeWUqQwk6EpEHiNDVpMPjQIelYeF/XKFjS7h6z5ZwPAH/Y+m8oGZyQNEhss6T4Gg3YsmUV
ABs3HvKhQ9K8otzXHbhVKUO9voQkjQJXAZfis5Mv6VhFua+746FKOe7pHoNiKdM9JA0GI/wdnosO
z4WicrqHpGNV+l7mlBP12rJO95CkKIzwd/hA3mG9UFSbNlknJR2b0vf10p+v0WYmhaSBZIRfc7Fe
SIOh9CixpIWZ/aVeMpNC0tCxYxtPhIcO64U0GMx4krqLcE81+0ulGKRQVxEaSGkuURaVUkeEh44o
9cK2U5qfO51IC4twT/UeplKc7qGuTPNSZD4IxhFpmkWEemHbKc1vagouuCBGeyFFFOmeqlgi9HGW
i9M9tCiOdCi6YWigh0Wk76J0WWw7NZ9h6lwuRZSMJymqUW8jNL8IGTb9YJBC87KBlHSsfOjosO3U
fEalc3ksnOsuzc97quYySoMgTvdQV6YsSzpWjhJ32HZqNtO3JR0P76mabdimyjndQ4vmSIci8wYe
i99Dh22nZvP6kHQ8bDM02yhl2JhJIWlgOVotaZBEabMM8ErSYBqm9rtbJoVBCkkDydRpSYMmSucy
SrBEkjS6nO4haeiU7uRL0vGK0G6N0sJrkqTBZJBC0kAapXl5krRcIgRKJEnqxukekgZWlNRpSRok
TveQJJXmmhQDygcwSZK03OxfSJJK6xakWNHPguj4TE6OMTnpjBxJkrR8ajUDFJKkuMykCMqdCzQf
R8AkSZIkDTIzKQaQD6Cajxk2kiRJkoaVmRSBubCVZjPDRpIG1+HD1f9XOEQkSRpx3TIpHI4NbNMm
gxM6mhk2kjS4rr9+FQB33rm/cEnU5hRKSYrHTAppwJhhI0mDZ+dOOO+8tQB885t7mZgoXCAB3lMl
qRQzKaQhYoaNJA0ep3jE02jAli1VdsvGjYecQinNYqaRSjFIMQcvSEVmvZSkwTMxAVdddfDIscrz
fip1116o3Uwj9ZvTPeZg6p80GAwoai7WC0UVZeFMr5EO+3zS3FysXb3mdI/jYOqfNDgiRPjt7McT
oV5IcykdnGjzGulwCqU0N/s1KslMilmmpuCCC4waStFFifA7ChdLlHph8EpRRblGovBaleZnHyee
YWqzzKQ4DvU6bN68/8ixpJgiNM5mXsUToV5Ap2N35ZV27BRLlGskSkfbrBJpfmYaxTMqbVaxTIqU
0g8Bvwv8JNAE3gv8PTAJ/DjwOHB5zvm51vtvAq4BXgSuyzk/0O3vX8qaFFFunJK6Kx3hN/MqptL1
otGAc8+t6sW3vmW9iMJ7e0fpayRKGcwqkTRIhq3NippJ8e+AL+Wc/0VKaQxYA3wU+HLO+bdTSh8G
bgRuTCmdA2wCzgEmgD9NKZ2dcz7ci4LZgZEGQ+kIv5lXMZWuF9PTsHdv7cixdSOGURl9Ohalr5Eo
WWj29yQNklFqs4oEKVJKpwBvzjlfDZBzPgQ0UkqXAhe13vZ7wFepAhWXAdtyzgeBx1NKjwFvArb3
u+yS4ojQWF9+uQ880ZSuF/U6rF5dHa9bV7YsqkR5KI6i9DVS+vPbDDRLGiSj1GaVyqR4JbA7pfR5
4KeAvwZ+GTg95/x06z1PA6e3js/k6IDEE1QZFZJU1D33ODqrozWbMDYW50FMfhfRROpol84qkaTj
MSptVqkgxRjw08D7c84PpZR+hypj4oicczOl1G1dieHclkTSwHB0VnOp1WD16hi3KNdhqER6KFYl
Skd71K8NSYNlVNqsUkGKJ4Ancs4PtX7+z8BNwFMppR/NOT+VUjoDeKb1+13Ay2f8+bNar83r1FNP
ZmzshGUutiR1rFwJK1ZUx6edto5TTilbHsUwPg6f+ETVkXjVq8rO97jrrqocV19dtBghvP/91f9H
pYOnwWEwUVFZN1VKkSBFKwixs7X45aPAW4C/bf13NfBbrf9/sfVH7gW2ppQ+RTXNYz2wo9tn7Nnz
fK+KL0lH3Hxz1YweOHCI3bsLF0ZhbNxY/b9knWg04IYbqlXAL7xw8FcBl4ZVhJ1OpLlYN9VL4+Pz
D+SU3IL0p6i2IF0J/APVFqQnAPcAP8ZLtyD9CNUWpIeAD+Sc7+/29y9lC1JJOlaOMigqt8iV4hu2
LQU1PBqNzj3kwQetm1p+IbcgzTn/DfDGOX71lnne/+vAr/e0UJJ0nAxOKCrXYZDi8x6iqGo12L+/
dCk0qooFKSRJUm9FWJzQbCNpfgYTFVWzCTUbbhVikELSwPLhR1FFqZulPx9gctI5zdFEqZ+qRAgm
SrPVarBqlbPnVYZBCukYRenURShHhDKADz+Ky7pZcZvemKyfsZS+l0pzMcvnaFH6vqOi2MKZvebC
mVpuUVY4jlCOCGWIstiYNy3NFqVuQvn66eKd8USqn5JiK30PiSRC33fYhFw4UxokUUYDI5QjQhkg
zg3TEUnNFqVuQvn6Wa/DW9966MixyotUPyPwIUyan9dFJUrfd5QYpJiDNyzNFqUuRChHhDJA9cBz
yy1l0xC9aWkuUVJkI9TPRgPuu6/qatx66/6Rv0Yi9C+i1M8oSgfyJMUXpe87SgxSzMEblmaL0qmL
UI4IZZip5I3Dm5bmc/nl5e8fEepnrRajHFFE6V+4UGMlQiBPmk+EoKYq0fq+o8A1KWZxrqbmE+Vm
EaEcEcoQ5Vp1jqLmsm3bGLVa+XoRoX5GKEMEUdosdbhmiiKL0HZG6O9F4blYfq5JcRxqtU4llGaK
0ihFKIdl6HBEUrM1GnDzzasB2Lhxb9EHnwj1M0IZIojSZqnDNVMUVZQsnyjZXxHYhveXQYpZ6nW4
+GJvWFJ0UVLvvGlptulp2Lu3czzq9TNCGSKI0mapwzVTFFWEdjNKoESjySDFLI0G3H9/dVqmprxh
SZFFGKE1/a/Dc1Gp1+Hkk6uTsW5d4cLoiAj1M0KbpQ7XTFFUEYKaka6NCO23+ssgxSxWfmlwRLhe
TYXs8FxU6nW49NJD1GqOmEcSoX5GaLOiOHy4+v+KFeXKEOFBUJpP6aBmpOsjQvut/nLhzDlEWKhG
RzOCqohcCK/Dc9HRaMC5566lVoOHHy67JoUq1s+jRQgQfPCDVRr5nXfuL1cIYpwLKaoI/W/b7+Hl
wpnHqXTkUi9lBFURGTTr8Fx0TE/Dvn2dYztU5Vk/j3b99WUDBDt3wtatJwLwoQ/tZ2KiSDEAuOce
+xfSfCK0nW5qMJoMUswhwgWpDhfuUVSRUiFL81x01OuwZo1rUkRi/eyIECCIkrVg/0KRRchiiKC9
C49TKEeLQQqFN+qNs2Iz86rDc1Fpr0nRPlYMl19u/YQYAYKJCbjqqoNHjkuxf6HIzCKuNBpw771V
YNVdeEaHQQqF5wiYIrOT2xHlXJQefZq5raG7RMVhWn8lSoDgjjvKrkUB9i8Ul1k+HU6hHE0GKdRV
6c5+W4QR2ijnIko5IvBcaC6lR59qNXjhhSIfrXnY4T9ahABBhIwOiNG/UIf39YrrMHQ4hXI0GaRQ
V+2dTq68suxNPMLNqvSDT7RyROC50GwRHkabTThwoBai3VLF7+JoUQIEEVg3YolyXy8dLKnX4eKL
nTYI1b//4x8342nUuAWp5lVto1dt+fOtb432lj9Rtj+KUo4IPBeay9QUvPa1awH47nfLbP/5d38H
F11UleHP/3wvr3lN/8ugl3J7cSm2SPf10u1FpHMRgVsFDye3INWiVHPAakeOR7mBjDLSEqUcEXgu
NJdGozPVolS7Va936qepqXGY1t9RepRYmkuU+hghIy/KuYjCNYU6RqX9NkihedXrsLYaDBz5jnaU
xbWilCMCz4XmEmGUZWICrrjiICtWlF2YUEcb9g7d8YiSUi/NFOW+HmE9iCjnIoIIQaNIRqX9drqH
utq2bYxabfgvhGMRJXIZpRwReC40lw9+sOrM3HlnucUBt26tOhFXXTXa86p1tAjfh2nkiizCNQIx
7iNRzkVpU1NwwQXl26wI38ewtd9O99CiGZzoiHKTiFKOCDwXmkvpnQsaDbj99qqD+7a3lR31iTDi
EqFjF0WE7yPK92C90Fwi1IdGA+6/v/w20hHORQRRskpsv/vLIIW6inIx2JlRVNbNeEpP+YhSF6Kk
yEbo2EUQ5fuwwy91F6UNV0fpNYVsv/vPIIUGgp2ZWHww77BuarYonYgI12eUjh2Ub7cifB9tl19u
h1+aT70Ob32r239GUrr9LP35M5Vuv/vFIIXCszMTjw/mFetmTBG2Kis96gMxOtqROnal260owSso
v1J+pHohzdZowH33VdfIrbeWm+6hOGy/j9aPfpYLZyq8KAvmqDJsi/YsxdQUnHtutQXOww/vHelz
EYkLnlUajU7b+eCD5a7Vu+8u36GK0m5FqRcRzkWEeiHNZWoKzj+/fNupWGy/O5arn+XCmRpokaKX
cgRspmYThjXQO6h27oStW08E4EMf2l9sC9DSo/ZQXasRrtcIqakRzgPEKEeEMkCMbCNpLhGy0CDG
Q7E6InwPEcrQr36WQQoNBDszcRg06qj2Uq+FuGlEEKFDVXrRTIgzDSjKtRohNbVeh1tuKX8uIohS
LyK0F9JcGg24996q3dqypdx0jwjBbsUSof3uVz/LIIW6itKJKP35OppBo0qzCS++WLoUcUToUE1M
wFVXHTxyXEKk9qr0tRolYNMW6bspqXS9gCpduFaD3/mdslsGS7NNT8O+fbUjxyXarUYDbr01Ttup
OEpnJ/arn2WQQl1FeOhQPHb0K9PT8MILneNR7kRE6lDdcUfZh556HX7hF8qnCkP5a7X057c1GnDb
bTHqZwSlv5edO2Hbtipd+IYbyk3LkuZSr8Paarkp1q0rU4ZaDfYbvwslysBthOzET36y95XTIMUc
olTC0qKNgEnR1OuwalXVYJTqyLSVbrcidahKT/loNOC//JfyqcJQvl60p1nUam7HGknpevHUU53j
732vXNaTNJd6HW6//YWi7VZ1jZafTlq6rYgkwsBtlGezyckxajW48srenQuDFHNorzjdyxM/CGyQ
pO6aTTjxxBgXSumbZ7MJNRsNoMqqef75sqnCbaXrRVvp9WWjLIQXxd13Vx3MUvXizDM7x2ecUaQI
CirKQ3HpNrP97y/ddka5h5QWJThQ+rqA6lzceONqAC65pHc72xmkmKXRgI9+tKqEl1wy2tkDERZn
kSKr1eBQgPt2hJtnrdbJKlEMEerFzGkWJe+pjQbcd1/V5bn11rLZLaU1GnDzzVUHc+PGMlsnr10L
K1dW7UbpLDR1RAgQRHkoLv0wWH0XZe+pEe4hUVTZouUjBBGezZ58sjPV+ckne1cOgxSzRFgsJ5II
i2tJUTUaMdakKN2Zghg3zijqdTj55PLTgCLUiwhlgDjbsUYwPQ1793aOSwU1V67s/+fOJcKDeRSl
AwQ+FHdEuEa8JjoibTlf+tls5nXZyz6OQYpZIiyWE4kNlDS/0msftEUJEJS+cUZRr8Pb336IFSvK
fh8R6kWEMkQqRwT1OqxZUzaIFqnDX/rBHGIESiIECKKMVkP576Reh4svPlR0XQzbzY4qW7R0KWKY
mIDx8eaR416pRblJLLfdu6cX/Q/btq3sXM1ISjfSUmSNBrzudVVU87vfLZM23ea1GkejAa99bVUv
/vZvrRftbXpPOKFcGSDGuYhi27aya29NTcHrX78GgG9/e1/RaUAbNlTl2L69XDnaa6GV7HdOTcEF
F5Q9F40GnHtuVYZvfavc9wHlv5PqXKylVoOHHy53H7Hd7CjdbraVrpuPPAI/+7NVH+fP/3wvr3nN
4v+u8fF189YsMynmYHCiY+vWqoq8850xFl2zkfRcRFKrwdq1MQK91oc4nnyys9NJL+drHosI9eJD
H6qGn+68s+z2LxHORRSXX17+nn74cPkvJEKdiJDBADF24okyWh1hS+0I07LAPudspc9DhPaiX1nE
BinmULoCRtFodDqXb3972bmBEdIxo/BcxGEqpObSr/max6J0B3PnTti69UQAPvSh/W41GcT116+i
VisXOJqe7gTySj6ARXkwj6RkgnW9Dh/7WPl7aoQttaNscX799TGCzKXNXAS69O4epadEnXEGjI1V
ZZm5U9NyM0gxh9KduihyhhdfrE7Co4/CeeeVKUeEqGEUnot4So9I6qVKt+ETE3D++S8eOS6p9Jba
K1aU30KvrXS9iGLnTti2rXzgKEq9gPIP5jffXDZQAnF24omwtlFVH2pF24oIZTDI3BHlvhFhPZ+q
rep9GQxSzMGR6kqUCzJKOSLwXMTTfgi86qrRbi8gzkNg6Ta80YDvfKfKh5yaKvfgEWFL7YkJuOCC
F6nVygdsSteLKPbu7Vyr09Nly1JalAfzHTtOoFYrO9e9VoMXXrCTAZ17WMlnwQjZRlEWB4+gnXXV
Pi4lwq4v9Tr82q/1/lwYpJjFkeqOlODEKoDK2WeXK4cp9R2ei1gaDbjhhqq9eNvbRru9gBgPgRHa
8OlpeP758ltZR9hSu9GAxx6LEbApXS+imJjopJH3MlW3myg7qZUOqEKszJaDB8unt5TO/oIYo9UR
TEzAVVcdPHI86prN8m1GvQ7//J8fOnJcSj8yngxSzFK68kVSr8MnPvFC8RREiJT+V76ORDgXqjz5
JBw8WDtyPMq7OER5CKzVYqWRlxThQbB0e9kWpRylr1Oo6sVv/mb5rWlvv718/yLCVIsoo9XVyH35
oGbp7C+I0V5Ua1JUxyUDeZ/85GivRdHWaMAtt6wG4JJLyu220mjA/fdXj+9TU/uH+hoxSDFLpJHq
CJ2Z0tvstEW4YUQYJVYs3/te5/jpp1nSNkxLVXr0KcI1Cp295dvHJcxMoS+ZTl+vw223lX0QjHJP
jVKOSPeR0tds6c9vKz3VYmICrrzyYPEpUfV652G41ENxhOwvqPrfK1aUraBVNkfRIgBVm1V6KlIE
UXZbidJu9oNBijlEGamO0JkZpYuhmyijxFA9jNZqZetFhABaBFH+/RFGnyKskg/VubjvvqrtvPXW
MqMMMwMT7U5NKRHqaJR7aulyRLmPNBpw441lp6lFWQsiylSLN73pxeLXaoTslijZA9VWqGUjBNPT
cOBA57jUdfrhD6+mViubPQDl+531OqxZU363lSgB934wSBFUlM5M6UYhiij//kYDbr65SjfbuLHc
DSNCAC2CmWu1vPrV5coRZfQJyo/8RNg6buaDzhlnlCtHlAfBKO1n6XKU/vy2J5/spPWXmqZWq8EP
flD+hESYatFowO23l79Oofw9vdmEE04onz4Q5UGwdJtRtRWd41HOQqvX4eMfL18noHzAvV+KBilS
SicA3wCeyDm/PaX0w8Ak8OPA48DlOefnWu+9CbgGeBG4Luf8QK/KVfpCgPINU1uEcwHlgyVRblgR
0s2iBNAimJjojICVTtNds6Y6LhXhn1kvSna0q4Wtyjaghw8X/fgjXJ8jliirw8/87FLtRbMJ+/eX
r5wRFgaM0t+D8mWp1WD16rJlaCv9IBjhvh5FowG33lq+31n6Wait9HXaL6UzKT4APAK0L78bgS/n
nH87pfTh1s83ppTOATYB5wATwJ+mlM7OOS97VzDKA1iEh+Io5wJiBEtK37Cgqgsnn1w23WxUGsdj
EWXngnod3v72g0XTdGs12Lu3fOWIkKb72GNHH5d6+ImwPoeOFmF1+LVrO1vYlbqPPPkkHDoUY9Hh
O+4om3pVr8Nb3+p1CtW//2MfKx/Ig/LXab0Ol15a9r4+MQErV5bdCQhiZEi2y6H+KRakSCmdBWwE
Pg78SuvlS4GLWse/B3yVKlBxGbAt53wQeDyl9BjwJmD7cpcrUgUs/VAc5VxECZZEOB/1Olx22aHi
c0ZLB9CiqNVi1ItGA/7oj06kVoMtW8qsw9BolN/THWKsjdHeUQM6I2ElNBrwJ39Sdn0OdVTT9cpn
G0XIsImQzdFWespHpOu0dNYqlO/7RhFhfaUIOwFBjAzJdjkgRr+vtH6ci5KZFHcCNwAzq/3pOeen
W8dPA6e3js/k6IDEE1QZFcvOB7COKOfCxqCj0YAHHii/9VCUTkTpG0aUkepdu8rPG525QGTJHS3a
Sj6EzVyHouSaFLUa7NtX7vN1tGq6Xvm1YxoNOHiwU6YS5Vi7thPkLR2kKC3KKDHEyFqN0ucr3b+o
1ToLZ5b0jW9Uu9/80i+VrROlMyQhxvUB5esm9OdcFAlSpJTeBjyTc344pfSzc70n59xMKXWrkT2r
rVEewCJcDBHORZRgSQRRbt5RylH6Ghml/aoXMvNBo+RDR5TFIiNoNODAgfIPxRE6VOqYGbgqFVB8
8snOFoulp3uUrp/NZmfqS0lR5v1HUbp/ESF7IMruNxGeA6JkdUP5utmvc1Eqk+K/By5NKW0EVgP1
lNJ/Ap5OKf1ozvmplNIZwDOt9+8CXj7jz5/Vem1ep556MmNjJ/Sg6P3x3HNw++3V8bvfDaecUrY8
pb3//dX/R72TOz4On/hEdR5e9arRHn6KcI2sXNlJFT7ttHXFrtOVKztzzF//+jLlWLmyMzL6yleW
PRelv5Pnn+8c//APr2N8vP9lAPjBD2KU4667qnpx9dVlPj+K732vczw2Vu77yLl8OZ56qnN86qnl
zgXA5z9f1c/3vKfM5z//fCeT4sQTy52LlSs7I/cl72cRROlftBcRLfV9RLmHQPnngHYfB8peH1Hq
ZrvN6uW5KBKkyDl/BPgIQErpIuBDOed3pZR+G7ga+K3W/7/Y+iP3AltTSp+imuaxHtjR7TP27Hm+
26/Dm5qCw4eryczPPrsvRMqXYti4sfr/7t1ly1FalGvk539+VSstc3/R7+Sf/bOTWuX4QZFyPPII
NJtraTbh29/ey2te0/8ytH30o2Otc3GoyLn4/vcB1raO93LSSf0vA8BJJ8GVV65qHZepn40G3HBD
dZ1eeOG+kR6drXZ9qerFoUN7i7UXVeZA2XKcfDKsXl2V4aSTyp2LRgOuu66qn29+c5n6GaW9aDQ6
5Xj22b0j3e+M0r/4hV+o2u9S/YuTToKrrip7D4mk9PcBMepmowH79i1PGcbH5x9wLb27R1t76sZv
AveklN5HawtSgJzzIymle6h2AjkEXJtzLj85qYcipDZJkUW4RhoNuOeeqhm97bZy0z127oSHHqoy
x3btKrObROnF52YruSbFzBT60utztLfILSVS9lvptP6JCbjyyoOsWFF2y+KZi7mWmppVLcj3QtEF
bqG6PvftKz8lKoIo8/4jiLAAc5TppKV3v4kiyvcRoe/75JNw+HDvd2cqHqTIOX8N+Frr+PvAW+Z5
368Dv97HohV3+eXl14Mo3anTS919d3XZXnll+fpRWuk1U3LuNNSPPgrnnVemHBECBGecASe0ZtiV
3KoswpoUM7cg/cd/pFhWSaMBt99e9lxE6FC1lZ7HC3DeeS8W++y2CO1FJBF2OmnvCFRyPZ9I12oU
JXQhxOkAACAASURBVOtGrQYvvFAr3v+2vahUC9zGeBgq3fedOfgyc9H05VY8SKH5tUdoS3aoInTq
1NFowEc/6qKAbaWDaKU7D23tEdr2cQnT0+109rIjkhG+k5k7erzsZeXKEeFcQPkOFcRYFLDRgA9/
uCrDZZeVa78nJmDTpoPUauXai+peVk24v+SSvUVHJVeurG4kJbNKbr+9fFYJxBgciyBCsLvZjLG7
RxSl+3vVQr9mGsHR941e7mBmkCKoCKvIRihDW/vhp2REt3QDCaamznb99VX9vPPOMumIM9Om2yNh
pZRO66/X4eSTy3b22+UoPRp4+umd45JbkEY4FxAjWBJhm8ecO7s4lMy8AvjKV9rdvzInpbqXdY5L
7jxz4onlR6ujiDA4FkGE+jA93QlSlL5GoPw5ufvuaq2pUnWzmg5V5KNfovQAcjvQ3eupiwYpgird
GEQpQ1vph1Eo3yhAdZNas8a95aFah2Hr1rJbYz34YOf4oYfKpvXfckvZUcl6vRodbh+XVHrkPlJ6
bOlzEUXV0S77MDrzuigZ1PzKV+DZZ6sT8bWvwUUX9b8Mu2bsz/a975XL6GjvSFRSowE331w+qyTS
wFRpEQK8UdY2itD3nZl5tXFjuT5O6XVKIM51+uCDJ/S87TRIEVSEBjJCGaB6GP2DPyj7MBqlUajX
4dJLDxZvJCOI8CA4c8T8R36kXDmmpzvzAkuNuERZVArKj/ysXQtjYwYTI2nXhZLZuhEWrISjM0ra
2Qz9NnNl/Geemf99vVal1JdN4Y7QfkP5YE1b6fa7rfTUl3q9cw5KtRdR+r5RrpEdO6qFt0quCVf6
uoBqgO7xx6tO+De+0busQIMUgUUYAYtQhggPo1EWzJn5IHjrrWUfBEuLsA7Dxo2d1dDbW8OWUGXY
lJ1qUavB3r3lrxGAX/mValvYUplX09Nw6FDnuOR1GmEULIJms/OdlBLhXgZw4YVzH/dThI42tFPq
y0+hjHA+ogxMRWmzSk99mZiAK64ou3ZMhHoZxc6dsG1bNWB6ww1lBkwhxnXaXiS91wxSzCFKFLf0
50cpw9q1sLrK8ir2ABZlwZwIqakQ5xopvQ5DowEnnFAVYGqqbNbTbbeV3461PUJbsrMfYRpQFFFG
wSK0F9PT8MILneMS52JiAt75zrKBVYAnnugc93L7uG5mLihbcnHZCNrTOKF85lXp7IEIC9y2yxGp
7SwlwgMxxJj6EiXIDOWv036tu2WQYg5Roriq1Gqwdm3ZlrrqXJePDrTnxLWPS4mwDWqE1benp+H5
5zvHJb+Thx6q5ge+851lvpOZaeMl58/O3A6rVDkidKigfBCxLcI9NcIuDgB33FF49U6Onl7x9NNl
1tJJqXN89tn9//y2eh3Gxsrv7vHa174YYhpn6eyBCAvctstROkCwcyfcfXcVcP/VXy0XcI+QUR1h
6svEBFx1VfkgM5S/TvsVsDFIMUuU6GkUEUbAIkRyo2RStJXOHoiwDWqEzsyjj3aOH3us3I1rZhpi
qeyBmQsBlnwInPnZpcrxD//QOf7Hfyy3oGqEtjPKPbXZhBUrykdtIozGrV/fOX71q8uUodHoHJcM
8DYanR1XSpVj507Yvr3Kn961q+y2sKWv1fYCt6XV6/DWtx4qGjiKEviPEOxuT33p9W4SC4kQZI5w
nbbX3YLe9rMMUsxSq8ELLwS4IoOIMAIG5VOb/v/2zjxM0qq6/5/q7lkY2p5hBmQZGBaRC6JsCmJE
AeOCshg1JqK4RJMYTcQoalBRVFBURI1JzGL8Je4mioJLUHGBqET2RZa5wzAzzSzMwPRM9cwwa3fX
74/7Fu+pmuq93vecnj6f5+HhTld1vd++dd/z3nvuOedaMNJgwzhZOQa1VoOK8hcj/3ZZFK9sLCx8
rEQPWDgBRzpsNMcFuO2sYyHdA2w4/utHemtiwWaBDR0dHTbuEzsa9DeE+vvhBz9Ijn+t+l+bNuVt
GSFYNnV7YeFe0bZddu4RXcqqu+VOiiZqNdi1S99Agv5kxsKCuE7dWaKVXmBlF85C9EBPT74I09wx
T2dW696rz3pWnopUVHXjsVA/s7re1mDt2rytFUIOaXx+/OPbVXfAZI69zN3UQNt2WojmqF+7bi80
7ZYFx7+FlKjmSAotLJzEs3AhHH74kGqBRLCRTmolkiJtxuRtjf7o7c3bK1bozTEuuiitA7QKUYOd
1BcLqc49PfDiF+tG+ZSFOyma2Lw5P8VBO8dcezJjwVsHNtILLCyIIT3AtU8ZSUUadReBdR3ai5+V
K/MTLTTDdAGWL+8wsdNhAW3btW5dY1vLYWPBdoKNnOZaDWbM0B0YVhz/FjIXrdiqzZthcDBva6V7
LFuWOkT7OQK69rNSgV279K4v0b5P+vry9oYNOhqsFKK2YC+sPE/7++Gaa6bHKX/upGjCyi6xhclM
Tw9ccskO9cWohfQCCwtiSBOY+gNcqyo76C8C62gvfiw8OAHuvx9uvjnlNC9erLcotoCFgqpW0j0s
2E6wYS8sLH4s9AM0RlJohZHLivAHHaSjAWzM+SxEtkCj7dSad1o5JcoCixbl7YMP1tHQ0aHvrIHk
uHv2swdVo42sPE9TwXb9NVE9LctrUpRITw8ce+wgHR26xtHKZOaWW9KJAdqhTWUUaBkN7dxugLlz
87ZWX1hYBFpBOz+yjiywpbXosLIwr1T0vxe50JDfTdlYsZ0WsLD4seLslteW922Z3HZb3r7zTjj9
dB0dPT3wsY/pRgZaKPYLeU02zfmnTBt85BG9BamsB6HlODrttNbtMunuho4O/TS5/n6IMe0KaR33
bumoYG1uvRXqaVlF2m93UjSxcmW+I6kZdmdhMmPhxABIxqm+A6bpvdQ+8gdsHIFkxYEG+ilRVnbA
QsiP0dM6zs/Swvyoo4ZUFx31Ao2g2xdWbKd2fSWwUylfO/oLbJzEY+UegXwz5rWv1avboh3NAek+
3blT7/rQ+PdrOdDAhuO/VoPOTp1r11mzBoaGKk+0NaPxtMdmTw+cd94u9ehy0J+Hd5XkPXAnRRNW
Fh0Ar361h7KDDR0W0m/qfPazupUzLTjQIH0nH/mI7nfyyCN5W7tY5B//8cATbQ22bcvbmosOC47m
fffN27KIZtlYsJ2g70yElFJQL5ComV6gPbmEtNioo7VbbSGEHBo3Y977Xp3NmJ4euPxy/TpPmzfn
C0Etp6YFB1qzDi1nyerVeb0ULQeBvKa2A61+VLAW/f1w3XX6tSAsnGB2wglQT/c48cTiruNOCsO8
5z26FXUt7NrXr/2613n0gCUs7AZWKrrHcoGdI0j7++H665M537RJ5+GZHlqJ448v//p1LOTQWtkN
XLgQjjhC99QAKw7eWi3/b7pj4dSAAw7I25qOPCsRNhbGpYVjpK2kqC1cmM/7tJyaFgowWzmFJx1q
kLe1Cuhv3Vr+dZuxcIJZcnQXH2HjToomrHgNrVTUveoq5fMuMz7zGf3ogZe8RHenuo6F46AsOG36
+2HnTt3iQXPm5G3NxaiF70O7DkQdCzm0cjKn6UizcGqAhbEJaSKlvSsJNlJf1q/P21qnBtS/C20s
7Nz398PFF6fn+jnn6DnyenrycanZFwPZHoh2ilr9OaKFLC6rdZT1vfc2tqd7UW7tOWcdzajEMnEn
RRMLF8L55+9SP6/aSpiuFR3f+Y5uuHB/P/zkJ/phXitXwje+oe+8soCF1CwrD/CeHjjyyKEn2hrc
dVfevvtuPftpIYdW7rZopr5YuEd6euBDH9I/JcrKBoSF1Be5O1qt6mh4+OG8rRXNYYU1a/KjxTUd
aAsXwmteozv/lSmUmoUzk1NT9zux4PiXUU777aenA/Qd3lbWQ6DfF2XhTooWnHzyoPoAWLgQDjtM
N0zXChbChSsVG0bBkpHUxkJFdCsPcAt1GGRNCs2QSAuLUZn6o5kGZAULaRbd3TZ2iT/6Uf3UlyOP
zNtHHKGjQXs8WMKCzbKChXmWFSwU75S2QrbLpqcHZs7UrcNgJQUe9CPyyjrG2p0UTfT3wwc+MBuA
c8/dorpjvny5bpgu6N8I9WtrT2jqu4H1thbd3TBrlq6htoKFiugyBFMrHBPs7D5ZoLsbZs7UTfeQ
ucSPPqqjARqP89PMab7kEv1Q9jVr8ueI1s5opZLnVWty6ql5+znP0dEgnXcyba5s0uJH1150d+en
OGinGX/727pFRLXnenXk365Vk8JC8U4r1GowNKQ/OK680oABB7797S4qFb2IvLLuU3dSNLFmTX40
lmbYnZViThZCU3t64KyzbNSD0Pbya1/fEj09cOyxg6ph5BYWgWBjXFhZdFQq+hFHS5bk7aVL9XRY
yGnevBkef9xGHq82aWJXUb9fLZzusddeeVsz2qhWg5kzdb8QC6c4gBcdljzwQN5eskQnHUnbTlhi
82bYtUv/OfLe9+rXhEuO/7SZ/rKX6WymlzU23UnRhJWwu4MOSjvm9bYGFtIs6jp++lPdkwv6++Gy
y2z0hXaFYytYSHGQVfJljnXZaE8srWiApGPXLt2F4KJFeVvzuMvVq/O2lhOtpyd3Wmk+Uy2kh9XH
pPa9cvXVefuaa3QWYFaOLK5UYPZs3S9k7ty8rXmPWKiBYKXocF9f3taKhtO2E5awcPKMlZpwmzfn
98aevg5wJ0UT9XB60H1Y9PTACSfo7hJb8eKmEFldMRZSTsBGITwrWIg2kjuAcmewbKSN0DzTvc6q
VToawMYpDtJJcdhh5V+/jkwt0FoI1iOeOjp0J1ObNuVtLXuRniH6DxJ5ssbOnToaYszbmtFGFk7u
sjLv1I5AAzvzTnmMttaR2jKNU9PJbGFsWsDC/QHpO9l7b90UtbIintxJ0USlAt3d+pOIlSvhllt0
d4ktPLzBRi5aTw889alD6hXqFy6EWbNSX2ju0FrAwq6PBQ2QxkJHR7JfWuNi9uy8remwsTDJXbGi
sa11csFpp7Vul4mFZxnYKEJXqaTib9o8+9nw1a+m9imn6GiwMuG3cHJXqjGlP+9cuBBOPXVQtWC7
lWeqdLRrpURZeJbValCp2Bib9XpsmjVCZqRACvVN7Msv162RJ1MGi3SguZOiiZ4e+PCH9Y9Ls/AA
t/DwBhuGeuVK+N3v9CfaPT3wqU/pF/CsTyQ0x2lZ1YVHQuatynbZ1Gq6dSDAjpNCevW1JhIylF22
y0YeNakVFvrgg3l76dLpXdS1pwde+lJ9x788fUdrfJ5wQt7W2qkGG5GaPT1wySX6887+fli8OD3U
N23S0SJTXzRrUixenLcfeEDH0SznFDHC6aeXr6FSgV27yr9uMz098IlPbFe9RzZvhoGBvK2dZqG5
NpLpzUWmOruTYhi0Q/sXLoTzz9c9r9qCcwDSd1E/r1oLS2kW55+vV8S0zkUX6RcPkveFLBBYJlbu
EQs6ZGFGzeNYLVTrP/TQvC1TP8rGgrNbfgeaBRKl3dZKfbFQXwlg2bK8LaN+ymT58rytXc9n1y79
neJ6fSXN53ulAlu26NbzkTZCc7fagg2X0Rxa98iqVfn8W7OoK8B3vjODSgUuuEDnHrGS+iJPzDr7
bJ0aeWWlOruToglZLFLry69z8smDqg+LerqHtnd/8+b8xBUt76WFomtWWLkSvvlN/eJBFsJCLWiA
NNEeUPZdWTlPPYWn6nptrCzALIQsSweiljMRbDjyLOzaA2zcmLdlgcAykTVCpJ6y2bwZdu7UPTVg
5Ur41rfSM/V979N7pq5alT9HtBakVo7TtvA8qy+Im9tlYiFNDuD++/No5sWLdepz1GrQ0aHv0LRw
YpbciCpyU8rAPostKpX05dcHgBb9/fDhD8/mQx+a3fAwL1vDD34wg2uvnaGmAdINWD9WcLo7CAC+
8Y0uvvlNPf+ihd1ZsKFj/vy8LcNUy6buyNu+XS/S54478vbdd+togPT379iR/tPqC2mnNFNfmkOW
NbBQlR3gqKPyttaio1aDWq1GTTlUs+70B73CmTKvXLO+Uk9PepZ0durNLywUgQYbz1R5kobWqRpg
w24de2zePuYYHQ1WnMwWxmalkv+nSU9PSoXq7tazWTJytsjjzT2Soon+fv1d+/q1tY+YsaABknc/
Te70vPs9PTBjhm4IOaTxedFFKfn/3HN1zkeupyLV21qkIka638lTnpK3NaMHenqgq0u3L7r8afIE
++yTtzVTXyyELFvBQtRTpaK3IyqRGrQKecpdWe26LfXTTrTmORbq6ICNVIvf/z5v33svvOxlOjoe
eihvL1ums3MvN0G0niMWnDVgY2xaiNKEZKMuu0y/PkedIiNsDPimbGHBWwf1s+VrzJlTm/bRA7LI
l1a4WXKSVABdA3XbbbnD5s479XSccsogz3724OhvLJBU0KnCrl36Dw1t+vthYKDCwEBFbSIhFz6a
tQcsYCGXGGyELFtJlbNQV6inBy69dAeXXqpXjwJsOGxkBIemk0Ief6p5FKoFLNwjBx+ctzV37u+5
J2/fe6+OBll0WB7ZWyYWCpQDrF2bt2VKUJlUKnnEqjbavpLHHsvbRUY8+d5XE93deZV67SNmzjtP
tx6EFQ/qUUelXdpKpTFkt0zWrNHP1YTG/GFpJMqkvx8+9KF0k5x9tk40BzSGry9ZolN9e+XKvC0X
pmVjwbm6YUPe1hqb0Hhvatnw++/P21qTS7Bjwy1gxVny6lfrFz6W94jWCQoyxUFz0i91aBVUdXLk
c/zkk/V0yCMWZbtMLDgTZSqWptNI+zADsFGzBWzUTpS2Um4ktxsDU1tbVCrQ3V2ju1v3jujvh+99
bwZXX61bD8ICPT1w5ZXbufLK7WpGwcLCB+Dww/P2YYfpaKinAW3ZorvwkTvUWhXqpZNCc8e8+ahJ
DWTtBc3jUG+9NW9rRRvJSa2m8+rmm/O27JcySTWFalQqulGBq1fnba2dOEgnI73nPbo5HzKH+MlP
1tEgo63k8cXTESvORHlfrFuno0HumGtpgMZjN7XqtlSrrdtlYiUVyQJyPGqOzVSAOf2nhbTfRc73
3EnRRP1Ei5e8RPdkj9Wr80Go5cW14LmUaOrp7obOzhqdnboT7RDytlZUSU8P7L13jb331u2LsqoL
j4S0EZr2wkIFbitRJfLBrbUzKlMrZN2SspF9oRVS39+fUuVqNb1UJGgsbKsVPVA/xeGb35zR4DSZ
jsi6LTL3vmwsOGxkmok8HrZs5K55kcXwRkLu1mtpADjiiLyttSG0YEHenjdPR4OFiBLQT28AO2Oz
XhtDsz6G3JQqMr3X0z2a6O+H665L3fLRj+rljVpYdFjJRevvh4svTjtP556r4zzavDk/K1qziGjz
jrlWEdHLL9/xRFsLueDRWoxaqXxtwaEoQ7Y1w7ePOy5vH3+8joZB3XItTyAXf1oLQZlXvXSpXrHd
o4+GI44YeqKtwZYt+b2q6bCREUayUGGZSEem5uLHgg2Xzn7Nej5HHw0LFtSoVPTuEem8W7dOT4dc
hGqNi6c+NW/LDarpiIU5joX0G6gXYNbtkLJSz91J0UQ9jEYbCzekfHBq7TxBmsDUz5bXygOzEo5p
ZcIP+p5tOXHQ2gGTu9Oaxd+0vwto/PstFJbSxMqRghYWghZ2ZyE5eNetS8GjmzbpPEcWLoSZM9PD
XfPYTTnZlmHtZWLlqMnmNCCNZ6oFhzukSJ++vvQwWb1apy8sRMKBjWeqhXopVmr5yLGo5TSyUPsL
0rPrxS8eeKKtQVlrVCNdbodaLS2I64tiLSwUtrJCymlO/033nDgLOy79/fDBD87mAx+YrVovRe4y
aKW+yF1IWSyxbCw4NaVnff16PR0WTkaS6Uf77qujARpDMrXy/pt3RrXYvDkV+Nq6Vfd0j+OOG+KE
E4ZUo9BkRJ6WDZf2QhbdLRtpq7ScJdKpW2QRutGQNSm06rZYiISDRrst0y7K5Ne/zts33aSj4frr
8/Yvf6mjAWxEMVipz9HfD9de28W113bt8TULPZKiidWrbVRvPeigdKJFvT2dWbgQ/vRPd1Gp6EUO
WPEmW1iMbt6ce/U1U1/kqQlap3vIB4RWYSuwsetjZWHe0wP7719TPRlJOgSme1HALkOzDG37uXIl
3HZbJ6C3Uw2N96rWAkw6mbVy/qGxZoysQ1Am8jvQqq8ENnburSCdV9KhViYybVCreKcV+20hOrFe
BBp01wHJ4a6bfl5WFLFHUjRhpXprrQadnek/TQ1WqEdSaNHTk4z1jBm6xknusmhNIqykvlhYmFvB
Ql61hZ0OSBEty5d3sGxZB4sX62iQkT2yiGbZWKiUL500mvn2PT0wa1b6T8uGN6fraSFt54wZOhpk
ip5mPR85JrXGhVwQax7fbKEw4D/8Q97+53/W0QCNJxbIiLQykfM9LSfFmWfm7Re8QEcDNKYraj3L
rBSBtkBZ94c7KZqwsvDZvDk/3UPrZrCSf7VyJXz72zP41rf0KqL396cIm127dBfmckKlNeG3UlDV
Qh6vfFhq5lVbQE60NdM9LDia5XW1duGg0UEwS+nUSwvh9JCc7jNm6C3KoXHHS9NhI9M9tO7Vu+/O
21rFO6HxGab1bLdS20g6KbQieOVx4suX62gA+O1v8/Ytt+hokGlQWs4rK+keFo57l45lTSdzfdO0
q0vPseo1KZSQIYiaO2AWsJJ/Va+IXqu5w0Z+J1q1SqwUVF2yJG/L1I8ysXBMGTRW65eT/zKRRzxO
99oxd9yRt2+/XU+HPLZO6wg7uWOuVeAW0gbEli26jtWjjkrPko4OvTo6AC98Yet2mVgpnClT9rTG
xqGH5u1Fi3Q0gI0oSfkcke2ykc5lrfH5tKflba1TTizMs8DGPWJlE7tWSxumWkWPoXHuL6Mq2o2R
pZcdmo94nM5YCI+FlLdb16Hl3e/utpHuYSHkzYrzSubxah2veMgheVvTSSF3XLR27uVk5qGHdDQA
/N//5e2bb9bRYClVThsLjlWAW2/N29KpVya1GnR01Ojo0B0g0pGpVfBXzq80i7/JHWqtxaic5GtG
2EgbrrVTLGtyaD3XoXGTUtYtKRP5XNdaj8h5jaYDTaYUaN0jFiKZYfd6bBqUdcy6OymakDlgmjsu
8qGtZZzSSSf6R7Km0KYaXV01tUJ4mzfbSPeQOwuaRtIC8qFVpCd3JOSESmunGhp3XI45RkeDvDe1
vg+wsfiR+cNaucRWsOKwsRA6nZ4jFQYGdHOa68XBQW98SvutlfMPjY4zrWeqlagSmWqilUIpC1Br
zsGbj6bVQG6abtyoo+GZz8zbJ52kowFsRDNbSe+1UOBWboYVuTFm4Gu3hQzB1AzHtBA6fdtteVtr
5wngF7+Axx+v8PjjFW68UU+HBeTiT2tXUkZzaD28oTEvcdUqHQ1ysq+JjFyQOb1lIicRM2fqaIBG
p6rWAkz+/Zp9ISe2WqfPWCjeCY07gppRTxaw0BeyNohmnRALBX/l80vrWQY2TjqRcwo51yibgw/O
21qFXeUcp7dXR4Occ2sdgwo2apBZiFgFGxEdZTmN3EnRhHxAaBpIWZVeK+xO82QRiZUjkCxgoSig
3DHXDN+Wk2s5oSiTG27I25oONOmYWLZMR4O0nVqFraCx7oHWUagWdjrARg6tBQ1gI+2kpyevSaGZ
KiftlmyXiRUnhVz8adktGUav9SyDxnRardRaK0dZSxuhVRtD1hzQcrhbqM0BNooOy0h7zQK3Fubg
Mt26yGOs3UnRhIWQImg8qkyrWI2VPMnTT095vJ2dNU4/XUdDfXLZ2ak7ubRwtKGFnSeAww/P21q7
PjJsXO4Yl418YGqlZ8n84SIfWqMhH+BaKThy10eG7JaNhXFhxWFjgVWrkv0cGtLdBJELc60dWitI
Z79WZOADD+RtzVMDLGzSSTulWRhQniyi5fiX8xpZ1L9MpANNsyZFWTUQRkJGUmhFJoKNunDSYeXp
HiVi4cxssBGma2UH7OabYWiowuBgpSEFpUzqk8vBQd3JZXd3+l4qFb3xacWRJ1MctCYRVh5acpIr
o7DKRKY1aO6M/vCHeftHP9LRYMWRZ+FetRIiKx1HWrnu0kmjmW8vHYpau8RW0oAs1EyRO7SaTk15
FOy99+pokH0h22VjwYbLI6S1nqnbt7dul41MNdFKO5Ebt/K7KRsLp/CUVS/FwBTGFhbOzIbGSYTW
bqAFIw02ijlZmVxu3qx/HKsVR56FycysWXlbMy1J5szKcNkysTDZh8bJg9Z3Ind9NOuWyMWfloPA
QlFXsBHRIe9TrTx3aKw9oFV7y8opDrJop9bC47TT8vbzn6+jAeCAA/K21nPEggaA9evztlahXRnl
pFWrRM6/NZ0UFpwlJ5yQt48/XkcDNEZ8aTl45aZUkXZTxUkRQjgkhPCrEMJ9IYR7QwgXZj+fH0K4
PoSwJITwsxDCPPE77w8hPBhCWBxCeHFR2ix8+QDnnJO3zz5bR4OFXThIFYUrlRqVSo0TT9TRYGVy
KQuYymPkysSKI09602+5RUeDnOBq1ueQUU9ahRplzqxmmK506mqlnVhJ95A6tCJ9LITpgo3IQAtH
PIKN0yRkzSvNyCsLi59f/Spv/+//6mgAG/eqhQKJ0DgWtOoPSEeJ1npEOmiknrKxYL+tpMDLTTmt
e0TO8Yq0m1rL0F3Au2KMxwKnAn8dQjgGuBi4PsZ4FPCL7N+EEJ4G/CnwNOAs4IshhEK0WyjOArBw
ITzrWYOcfPIgCxfqaAgBoAbUVE866emBE08c4qSThtSOIO3pgc7OVBdDM3rAyvi0gIWCqocemrcP
OURPh5w8aC065ENL00khjx3VchDIh7bmEaSybo3cPS8TuRuodfIM2JhgWogKhMboHq1aJdJOaW4I
yQKRWhsQFupiQOPGh9YmiJX0MOnstzDX0MKCQ9MKsk6J5rNs//3ztiwUXiYyiniPi6SIMa6NMd6V
tbcADwALgfOAr2Rv+wrwR1n75cC3Yoy7YowrgKXAKUVok5NazUlEfz/cc08n99zT2TDpLlsD8ls4
iQAAIABJREFUVADdM91XroQ77ujk9ts7G86uLpNaDQYHKwwN6bpzLRx5acGjDY07cVrRAzJ8XYa1
l42Fh5aMsNGyWWAj7URGoWmekmShLywU44PGI7XvuENHgwxf17pPwUbNK7kYLTKneTTkPE9rx1xu
fGhG5MnIs3320dNhATnP0Yr0kc9UrTRjC6nnVrASXW4hsrusuYV6l4cQDgNOBG4G9o8x1n3K64D6
1PsgQGZkrSI5NdqOXARrHqO3eXPagduxQy+kXj68NZ0UMixWK0T29tvT/2u1xpSLspFpDTffrKNB
LkA163PI3WotHb/8Zd7WOsoPGndDtXbu5W6T5s6ThQKecuGnuQCT40Jrx1wuujSLjVk4UtvC0XHQ
6CCQ7TKRqQWa0Uby2lrpHtJmaTncodHprlU/xsomiIy8ku0ykTZLa4H8zGe2bk9HLDg0rVCWo1vV
SRFC6AauBt4ZY2xYBscYU57B8BTix7FyDq6F2gPyGFSt0xPARsEzC0WUoHESpbXokGFumiFv8qGt
NbGTkVeaoany/tS6V+UpAVonBoCNXHfppNHcfZEhmbJdJhby3IGGtMmDD9bRYCGyBRp3ybV2R6Vz
QDNCsKyw5ZGQmy8ypLxsLIxPOdfScqA1X1vr2W4hbdDKmsgCVhxoFk73kPdEkbVK1Pa7QggzSA6K
r8UYr8l+vC6EcECMcW0I4UCgngG1GpAZ3wdnPxuWffaZQ1fX+LdOZAjmk5/8JLXqwnKhsXy5jg45
we/q0usLufs0d66ODpnbfeSRen2x7755e/58HR2NoWZ6fRGjbOvpqFOp6GlozDHX0dFYaEyvL6ST
Qus72XffPLVB8znSWIROR8fKlXl79Wq9vpC7PdWqjg5ZOFPzmSon252d09teyHoQ69fr6JAFmGfO
1OuLxmg4HR1yIbx1q15fNC7CdHTI5/rOnToa7r8/by9erPd9yE25gQEdHXJTbuVKvb6QxXX7+nR0
yLpjRX4fKk6KEEIF+DJwf4zx8+KlHwBvBD6V/f8a8fNvhhA+S0rzeCowYj3/jRsndiZh2lVIcZj7
7LNFbdc87fokHfvvr6Mj7TB0Z229vkjpBUlHf7+OjjTB1dUAdYdNd9bW0ZGiB/T7Ij20ko5t23R0
SA07duj1xdFHw113JR3HHKOjI+0AJg29vXp9kXaJk465c3V0pEVg0tDZqdcXqR5E0rFypY4OC/Yb
6hEd3VlbR0cq2Jk07LXX9H6m7r03bNjQnbX1+kLOc7q6dHScdBJcd13ScOKJen2RHKvdWVtHR4pm
0Z93pujMpGPGDD0ddQ2Viv4cZ/t2vX6Q885qVUdHKmqbNKxapdcXcq61bJmOjpSumDTMmTM5Dfvt
N/xpBFqBqM8FLgDODCHcmf13FvBJ4EUhhCXAC7J/E2O8H/hv4H7gOuDtWTpI22ncnS3iCmNj0aK8
fdhhOhrkoNNMcbBwbJuVMC8Zjip3X8pEhnZppjgce2ze1ipaaSE8FmwUEZVhoZq1SmQtIa1CjdJ+
a53OBI2h/FopODJ8XTNt0MK9unhx3tY8gtQCFk5bgcade60USnmih+YJCjLqSRa8LRM5FjRPUhsa
0rt2HQvPVFmH4oQTdDSADft99NGt22UjbZZWCo5MdS5ybKpEUsQYf8PwDpIXDvM7nwA+UZioDAtF
lMCP/ZHIFIfpXnFaLrq0FmBycqnlKAEbC3NpnDWLy953X96+914dDYsW5ZNtzeNYLeQSy6JSWseg
go0q4PLEAFkpvmwsVGa3cpShrBOiVQ/CSmFuea9q2QsZOq1ZRFSGbGvdqxYWo9CcaqGnQxsLtXyg
8bh3LR3S6a+5FpGbIFp9UdZx2gYe27aQEzl5fnbZ/P73eVtr0WHBWwfwghe0bk9H5OJPc3xaQO7K
au1KysmLnGiWjXQWaRV/a8wZ1dEANhajMpqjt1dPh4VCu4cfnref8hQdDdBoI7QK/spFoDw2uGws
2C0rR5DKyECt41jls0yzGLXcENMqWim/A81ITQvHSMvNF63nujxRrn7KnQYWoo1klI/mBp10/Gsd
ZS1rFhZZoNzAdM4WchBqHTsENtIL5IRK3hRlIwtnaoX/HXBA3tacXMrdDa2iPVbuEQupL43FZXU0
QOMkSktHY/FOHQ3QOD41w8gtICf5WosOGUKueay3LJAoJ7xlYuEUHmicX2jNNSwcmwyNi2Kte0Qe
663lKIFGh5VWJLF8jmg6uy2kO8s5joXTmTSf6/LEwzvu0NEgN4wfeEBHQ/O1tXTI8VhkJLM7KZqQ
YStbJ1Z7sy1YyIeTRkErmgPghhvy9m9+o6NBhrxpRjDcfHPrdplYCccsy5M7EnISpXnUopxEae0y
yGgrzUWH/PuLPBprJFJRqd3bZSP7Yu1aHQ1WHLwWUl8sOtC0nBQWNmLARhi53LXXdHZbOC7YipNC
zsG15uNyXqOV0io3QLQcJWAjWlSmWGs5usFGlHtZ96Y7KZqQE0rNXeJbb83bt92mo0EW+ZLHEJXN
736Xt2+6SUeDBUcJNDqLtL4TK5NLCwtzuRjX3GWQztUi8wNHQi6CteqlQGP0gNa4sHK2fOMxYToa
ZOqi5nNEFg7VKiJq4T6FRkez1sLUSs6/fJ5pLQSlzZIRP2Ujw/m1dqsbjwrW0QCN41MrJUqOC61o
Dit1t2QUtYyuLhN5Xc3NBwuO1dWr83aREZLupGjCgicZGtMrtCZUsv6BZsEcaRi0jJP0mmpVvQYb
+fbSo625GxhC3j7qKB0N0qOv5d2Hxt1qrTQgOcHXmuyDjVMDrORVy1NvtKqRy1B2rXB6aFz8aTmv
5MRW03ZaSA+zcoqDXIRpLYrlvEYW5ysbK5t0FpBrASvrAg0sFGmExvS4hx7S0SAjMzXr6FiYg5cV
XWRgyWMLC5WeofFhoVVFVi52tIqzABxxROt2mUivoeZOh4XvRBpqzaNp5c69lg5pqDXTYORCUCtN
zUJoKtjJdbeAnMxpFeSTdXQ0nyMWTlCQzw5N2ynvEa1IHwvFO6HRSaOVNmhlQWwhldNKuoc8VU62
pxuy8LPmBp20U1pzHHlvatosC87usiKq3UnRhIVifNB4Q2qdjyw96Zq7xFKHlndffh+aIW8WJhEW
ivEBLFmSt2VqUpnIyb5mDRvpsNHKlZR/v2You3QcaU345W6o5s6oLFqpdcqIlfQwuVuvtXO/fHne
1iycaQELRRqhMWpVa0PISuqLnOdpOZpltKim7bBQF84CMnVTbtaVjYVnqqyppOlwt7AOkGuxItfK
7qRowsrJBdIxobX4kQs/rSMewcYkV4bHau4SW6jDIKONNHNGZREnzYJOFpD3iNYDzMKDExodihYq
1GtOdi1UqJdOTc3oxAcfzNta4cLHHZe3n/50HQ1OI/IZprUhJOcUmptjFhbmFuroQOOCXDOCQBsL
RRrBRrSRjFjVshXQGBWpFSFZ1uaxOymauP76vC2LJZZNf3/e1tqttlD/ABon11qT3Pvuy9uaxd+k
g0BrXMidJ81dYhnRohndUkfzfrFw0on8+zX7wsKupJzAaE5mpHNVy9kr0z206iuBjaMmp3NuezPS
RshxWjYyIi9GHQ1yI0rTXliIpJBYcJqAHQe8BnItIttlYyGKwUrkrHx+aT3LpH0ocs5pZBlqBzkI
NR8WcvEnJ3ll8tSn5u0jj9TRAI2TS61iNfLhrXlEmPz7LfSF5q6PvFe1dszlwk8z4kcuxrV2n+R9
obnokBNKrUmulYmdLH582GE6GqSTWTM9zMJC4yc/yds/+5meDgtYSMuCxjohWsf0yjmO3K0tG3nU
umaRRAvIvH/Nwq7aWIhggMY5ntYcR859NSPtLUQzy43BIh027qRoQu70aDkHwEbev9xV0Ez3kHmi
Wjmj0mGlmT9rYWEux6NmhWMLWDjKD2yMC+mksRKFpYUcF5ohyxaiB6wUo5aLYq3vRNqI6V7U1QoW
iohaeY5YKZJoASvHBTsJWcNHpu6ViYVjaaEx1VsWsi8TmQ4la1+1m2k+ldwdC2E00Pjg1DKQ0iGg
6Um2sCi2MMEFOPzw1u0ykTssBx2kowEavxMrYaFaWNgllt50zVBIJ8fCPSJ3Z2VkR9nIelNaZ9zL
jQ/NTRAnx8KOuQUNYKPmlRVkCLtmZKA2Fpx4YONZJp8hmkdIWyhmWlbkrDspmpAPC62JDNhYdMlj
l2Q+WNnIImdaFdEtLALBRuEeC2MT7BxVZgG5K6sVSWFBg9OIhbotFop3QuOOk1ZEhwwXnu7Ffq0g
nQI9PToaLBT7hcaIWVmrYzpipfixNjJdUTMVSd4X0nFSJn68eY6cTxS5FnEnRRNyMa55NrKFM91l
EdGf/1xHA8B+++VtWbSxTORERtN5ZSGMXhYOfeABPR1W6kFYQ6svrBTOdGwhIwE16zzJ1BetPN7p
vNixinQQaEWAyTRjzfmFXAhq7ppbQN6rmqH92ljZuJVzcK0oBpmKpTkmTjwxbx9/vI4GuS4t0mnk
U8km5KJLK+8JbBxBaiX0T4bdae0+yeJamn0hF6BaBTytHCkoJ1SeXpCjtRCSO09+ioE9tJxXMhRU
03lloaCqhWNQnUYs1PORCx5NR5a029M9OtFJyDm3jAQrGwv3yJ135u277tLRAI1OTc0T9srAnRRN
yImMpqdMLkC1JnYyf1jmFZeN9JpqGUm5CNY87lLq0Aq9s5L64tjFd4xtYOEEBfkc1Vz4WNgxt7IT
5+RYCOG2cIIZ+LPd2R2ZJqe5QWelNoYF5KapbJdJWbUC3UnRRFnHqoyGhUm+jObQNApyt17rOD/5
8NbcDZSTGS1niSzaI9uODTzVwqljIdrISgi5hRRKeWKCVsEzpxE5z9FKR7KSKic3gTR3zR07WImE
k+n3Wmnf8royDb1sHnmkdbtMyopA8+lsE3IRqBnKLh+WWjvmMjRVHkdaNjKnWWthLq+r5SgBG0cK
WjnpxGmNBQen49SxUlBVOmm0nCUWnmVOIxaO/7Qyv7AS9eTYQdoszY3bFSvy9sMP62iQKfBaEQxg
4zuR0f4yJb/duJOiCVk484AD9HRI76VW7QELaRbQWCdk8WIdDfI4VtkumzlzWrfL5DnPydunnqqj
wXGc0ZGnFezpuaujYWFHcNGivH3ooToanEasHCtYRzPlwp0UTjMW0yy0nIkW5t/QGD2hFc1c1klV
7qRoQkZPaOYGWphQ7bVX3tY8u1tGdGgVM5VGUXOnuqxjf0ZCHlMmvduO49hC7rjI9nTEQlFAGQmn
uWPu5FhJ5bSAnP9qHhfs2GS6n6JmpTi4TBtcuVJHg7SVcr3abpT26O1iJZTdQm6g9JpqTnDnzMkn
dFp9YSG3GxqNgYUHhhd/cxy7zJ6d226tk5Fmzcp346Z7nrvcfdP6PpxGrBTFtoYX0SyPX//6Bm68
8ZctXvmIaA9w+eUf2+0dp5/+Ap73vDMKUtbIdB8TMtJKbuKWjYUaNnvtlTvdi3yuT3O/8e7Ixbhm
aJNcgGoNQumk0YwekDnNWo4jC0fCgg1PrswH9OJvjmMX6dQsMm90JKw8R8ra+RkJmbo53R02jj0s
zDudnLlz14u2UhEy5wlkJJxWrUCw4aSQ6+Mia015JEUTVgqjWHhAWCl4Jr23Wk4KObnUmuBCY+SC
zBUsE7nbJI224zi2kBMprfRF6UzVOlUDbBzHKucU08XBO1V2ia2gGSFpoYjodOR5zzuj5Ti/5BJ4
8pPTl/Lgg08Gdr9HnPKQKXpaheuhcR2ktSYq6zhtd1I0YeHLh0ZnidYpIxYqyIKNYk5WalJYQ9Nh
4ziOM5WwcsS5DfxB2orpHlLvNPKqV12UtdxBoY3crNXaJITGKAatiH/5LCsyqsSdFE3IB4TmYlQ6
CLTCiuQNqVmTwsLxXNIQaBWstIKcXE/3vnAcxxkrM2fmba1Tu8pmLLvEjz7ahS/CphceYTM2Fi7U
VuDUkZukmlGB04lp8pgcO3LiMF0mEY7jOFONiU5yp9MEt6srn1hp1aRwcmThzO5uPR1WOP103yV2
mvEIG8cmnZ15VLXm+nD+/Pzo0X320dFQqeSb+n66R4mUFcLiOFMVC+k3GrReFH9EtH3XxwJPetJG
Nm/uydrFh15ZHhfy/vSTePSRRYd7e/V0WOH447UVOFp4hI0z1bBwjDXA2rV5+9FHdTSUVb/GnRSO
44yLvfeG9VnRabkzOD3xXR8txjLJfeihBehMcn1cOLvjTiPHGZ3TTvMIG8cZDgtFoMvCnRSO44wL
C0fCatBqUey7PjZ5xSvKm+T6uHDGigyRtXCCl+NY5KSTtBU4jl2mUxqnOykcxxkXXjizkWc8w3d9
rHHIIdoK4LjjfFw4jcgdsDIiKbxui+M4zp7FdCrg6U4Kx3HGhQwv29NDzcbCmWdqK3AscsYZ2goc
pzVz5mxi69aerO2eZsdxnKnInn5ksTspHMcZFzJ6wiMpymX4ndEPi3bxO6OWi0U6jpMYS92WFSvm
4dE+juM4jjU8K9JxnAkz5PUBTXDhhR8DakAta2vgg8FxpgrnnXcR55130ehvdBzHcRwFPJLCcZwJ
48XfymW4nVGAL3whLTguucSLRTqOMzKHHaatwHEcx3GGx50UjuNMmDIiKSZa/A2mV3rBhRdqK4Dn
PteLRTqO4ziO4ziTw50UjuNMSWbP3sL27T1Ze+so73bK4JnP1FbgOI7jOGPDT8DJ8VpTjjXcSeE4
jmnGUvzt4Yd78N17x3Ecx3Emyz77rGXjxp6s/aiyGj26urYzMNCTtffw8y4dc7iTwnGcKcs553h6
geM4juM442csmyAxHsR0mGOMVmtqzZo5FN0Pnt7rSNxJ4TjOlOWII7QVOI7jOI6zp/HqV7d3E+Rr
X/t/9PauGNfv9PYuB+Dyyz88yjsbOfTQw3j96988rt8ZjrPOsrAZ5KeHTUfcSeE4juM4juNMmDIX
YDD+RZjXHnDGy4EHtvfzentXsHzpcg7cZ9GYf2dO51wAtvcNjvl3Htn48Li1jcRRR7X140ZkLJEt
fnrY9MGdFI5jEA95c5yJLXzAxu5TmfgCzNGmt3cFDzy0lM75+4/5d4ZmzAZgycbN47rW4IZ143r/
KCra+FlOM1M1eqAoDtxnEW/9w/cXeo1//cUVhX6+Fs95joWIjulH6/mFvDeLW4u4k8JxphQ+oSoS
67uB04208HmAyoJZ4/q92owBABZXl439d/p2DPva1B0Xbi+c8uicvz/d51xQ+HW2/Ojr4/4dCzu0
VjYfynRq9vau4KGHlrPvgrFHD8yckaIH+qtjjx5Y39fe6AHHHiefrK3AqXPhhR/jC1+46ol2UbiT
wnGasHAMk4UJ1XSkt3cFDy69j559xv47lc70/3V9943rWps2juvt05bKglnMPO+Qwq+z8wcrh30t
OUsWU1nQPebPq81I9+ni6qpx6aj1bRnX+8GGvZiOCzALeLTR5Dn1VO0d2gHR1nQsFnPtfRcs4o9e
fkkhn13nmmsvL/TzHWe6Mtz84gtfSHbzkkvcSeE4yljakdSeUO3Z9OwDp764eNP4u58NtPy5lUXH
1I0eKIbKgm5mnXtc4dfZ8cN72vp5s2Zp2wsrtrM8HWU6bJID7UE65u83Lo21GSk6KW6sjvl3hjY8
Nq5rTBVOOaWc64zNmTiTou9VC05Nx7GMhc1K61x4YfHXcCeF4zQx2jFM2g/vMgxD2VhZmFugt3cF
Sx66j73nV8b1e0PZzv3qjfeP+Xce31AbUcfih+5j5oKx6xjMNCyrjl0DwM6+4XU4k+Otby3nOlYW
PlZ0tKYYR0nH/P2Yc/arCvlsydYfX134NaYrL3yhtjMxsSfm/fv8Isc3HyaDFYf79MGdFMpYCZG1
wPB9UU6BltHZ8x7eVujtXcHSpfcxb974fq8zS7VYv37sqRbVsW8cqrH3/ApPf2nx5vne61pHc9SZ
uaDCk8+dUbiOR3+4q/BrOHqceaYN23nsseXosO0ocSzytKdpK0jsiXn/vb0rWPbQcvafP/a6GACz
s9oYj28ce22MdRts18bo7V3BigeXcfDcsffFkzp6ABh4dOT5QjOr+ofvC+sFVS1sVvr6cJo7KWyH
87jHrk5ZBVpG16F26WnBvHlw5h92Fn6dX/1i7BMOx3EmzzOeoa0g8Yd/qK0A3NldHL5j7gzH/vMX
ccFLP1j4db5+3ccLv8ZkOXjuIt79BxcXfp3P3vTJYV+rO0sW9Swc8+f1VFJNqKF1wxe5bubhTavH
/N6xYcF+t399aDXCZko5KUIIZwGfBzqBf48xfqr9VynXOWBlx0XziJk6w/UFtL9Ai4UbcipMqCyM
C8dx7NgLt52Tw53dxZFS1B6ic8GB4/q9oRlzAHiwunXMvzPY98iwr1nYJZ7K94gzPVjUs5CLn/23
hV7jkzd/vq2fV6b9LnN92Nu7gt6lD7Jo7thrG83tSHWNao+NLzz54f6x1zaaMk6KEEIn8I/AC4HV
wK0hhB/EGB+Y6GdaCOcZGV2PXVERDBN5eL785e19cPb2rmDZ0vs4YG7HmD9rr440LrY+Nr4ht7a/
teOrt3cFDy29j/3mja/2wKzOpGPT+rHn/T9WbV/Ov5XIFseZTqQCiZHKgp5x/V5tRrIvi6vDL6p2
+52+TaPoWELH/Lnj0JDsbNy4bsy/AzC0oX8UDeM4hgeozejMdIx9kjS0YfhjeCw4bJxGOhccyNxz
iy/E0v/Dfx32td7eFcSHljF7wdhPJRqYke7r3urYU9+29418ItHSh5Yxd9/xpTh0zEw6Husfe2h/
/3rbKQ6O04qpbb/bvz5cNHc/3v+84msbXfHrsdc2mjJOCuAUYGmMcQVACOHbwMuBEVeME/Mm1wfh
4eMW2U6vdrsX5hPri1dm/2/dFzfe+MthcqZGdhAsf/A+Fs4de2h/d0da6O98dPGYf2d1/8hh/QfM
7eANp88e8+dNlK/euH3Y1/abV+HVZ8wqXMN3bhg+PM7KuHCcZqrVKrW+HSMeD9ouan07qNJ6RyDp
2NL2kzda69gyrI7Kgh5mnXNq4Rp2/Oh3I77eMX8us845owQdN4ygYR9mnf3i4jX8+GfDvpafrLFg
zJ9Xm5FqvMSNG8alY2hD37jeXzbVapXBvvVs+dHXC7/WYN86qhXbaXuzFxzCES+/aPQ3ToJl1141
4utz913E8//o/YVqAPjfa64o/Bp7AtVqlY0bN/Cvvyi2vx7Z2Ms+nfMLvcaeQEo5eYhFc8ceedXT
kaKuhh4de9QVwMP97Y28avf60CpTyUmxEJAz1VXAs0f7pRTCsoRFc8d+w77hFalbao+tH5fAh/uH
n3QkHZFFc8e++zS3oyPTsXYcGlrvPNU1rFj6AIfM3WvMn/f6VyRv+uBjK8b8OwAr+7eN+PrCuZ28
/bQ54/rM8fLF34zPiExX6hEd88cR0fHHr0yRGRvHEc0BsGGYiI5qtUq1Wk69iGoVurqGX4xu2jj8
8aDtZNNGmNW5u45qtcrjfbVRi1q2g8f7alQrw/fFzr5aKUUtd/bVhl2YO45lOuYvYPbZ5xR+ne0/
/lHLn1erVYb6Hivl5I2hvseoji/wz5nmVKtV+vo2cM21lxd6nfV9vdTwhfloVKtVqv0bRqwX0S5W
9T/MvJmtv5NqtUp1U1/b0zGaeXjTKubNGt6JvGjugbz/D/6iUA0AV9z0pWFf6+1dQe+DS1k0d/8x
f97cjrTBWnt085h/5+H+8UUyWmAqOSkmFK9erVbZPjBAb3V3B8Lg0BADQ8PXoFi3pfWX39XRQWfH
7mkCOwYHqA5zdECuo9GJMJqGpGPLmHWMpmHHwBArq7s7EAaGagwODd/Fj27Z2fLnnR0Vujp2n7Xs
GBwaUcfavkE++OPG/h0cgoEJlgTp6oDOpq9kxwAcMHMkDUN8+trdHRmDQ+m/8dLZQgPAzkE4YEbr
xeja9TW+eM3ukRZDE9RQ19E8PHcNwNAIC/NdA9DXwoEwNJT+G45NW1qPmY4WGgAGBhh2XKTXdv/5
aBpGopWOgVHW/gMDyYHQLh0j9cVwDA4kB0IrDbUJaKgMo2FwlL6o7Wp9PGhtkImV7+mASosAqtow
fpB58+bxyDC537WtA7BtAk6tvTqpzGn96Js3zPEySUdrZ3Ft607Y1to+jqxjJpU5M8eso1qtUlu7
ge1fabGzPziJwdnKaO0aoEprZ3a1WmVoXR/bvnJN4wvtvlEBBgapVnaPNEsaHmPbV/9r998p4Eat
VlqfcJN0rGXrV7/SpGFwkn3R4iYZ2EW1Mkx64sAuhvpapLAMDSUt49bQOUxfDO+wTPfI7hs7Q9u2
UNv6+Pg1AJU5e9OxV3eLF4a/RwbWrqHvPz+y++8MDky8Lzpb2ItdO6hyUMtfqVarbF37CPf/v8Z8
+9rgALWJaAAqHZ1UmnQM7dpBlda7wNVqlb61j/CDf3/bbq8NDQ4wNAEdHR2ddLToi8FdO5hRG343
eteuHazv6238ncFBhoYm5ojv6Oiis7PxHtm1a/ho0Wq1ytp1j3DV1/9yt9cGhwYZnICOzo4uOlvc
pzsHdnBApXVfzJs3j43rd59cbN7Wz5btE3PSd8+ex5P2at78rAz7LAPYMbCj5ckbA0MDDE5gXHR2
dNLVsfu42DEwcoHLHQM7eXjTqiYNE/s+ko4uupq+kx0Dwz+bq9Uq6/rW8Lbrdk+ZKKIv9p85vL3Y
PrCT3iYnwuDQIAOjaFi3pXU6YldH527jc8fAzhHXZev61vBXP/yX3V5L69Tx90XS0GqtvIv9x3ho
XKVWmxrn04cQTgU+EmM8K/v3+4GhYopnOo7jOI7jOI7jOI5TNlMpkuI24KkhhMOANcCfAuerKnIc
x3Ecx3Ecx3Ecp22M/WgDZWKMA8DfAD8F7gf+azIneziO4ziO4ziO4ziOY4spk+7hOI7jOI7jOI7j
OM6ezZSJpHAcx3Ecx3Ecx3EcZ8/GnRSO4ziO4ziO4ziO45jAnRSO44xICGGMhwU5juM1nyCOAAAe
aUlEQVQ4ddx2Oo7jjB+3nQ5McydFCKEz+79qP4QQnhJCaH0ofXkanhVC6NHUYIUQwrtDCAdr67BA
COGjwN+O+kZnWuG2s0GD284Mt505bjudVrjtbNDgtjPDbWeO206nzrR0UoQQ/iyEcBfwTmUdF4QQ
7gOuBL6n4TnMNNwDXAp8J4Qwq2wNTXpeGUJYoHTtN4YQbgROBDaHECoaOoSej4cQzlS69utDCDcA
bwBer6FBEkI4O4Swv7KGp2pP6jIdR4cQ5ihd221nowYTtlPTbmbXN2M7Ne1mdn0zttOC3cx0qNtO
TbuZXd9tZ6MGt5247Wy6vtvO3XVMa9s57ZwUIYRjgLcBPwSeH0I4IsY4VKZXO4RQCSG8HHgr8JYY
4yuBOcBf1F8vScfLgL8C3hZjPBdYCLywjGsPo+dS4EvAaxSufRrwH8B7YoyvjzH2xxhVjr4JIZwU
QrgVeBrQW+YkIoTQFUJ4C2ksvi/GeDiwOoTw9LI0NOl5ZQhhMfAO4MshhGMVNLw8hPAQ8DHgS4pO
tJeGENYCnwL+O4Swb8nXV7edmQ63nY1a1Oxmdv3nYsB2atrN7PpmbKcFu5npULed2nYz06BuO33e
2VKLtu00Me9029mgxW1nrkHddk4LJ0UI4Un1dozxAeCNwOeAB4C/yX4+VJaOzAjdA7wxxvi77OW/
B14uXi9UQ8b1McbTYoy/DSHMAx4GukMI3UVdfxhN9XG4Dfhq+lF4VvZaYQ/OpnHxG+A24OjstYtD
COeW2Rfibz0a+FqM8RUxxmXAYAnXro/NAeDqGOPzY4y3ZJOrzUVffxhNTwb+EnhzjPEsoAso9YER
QpgP/Dnw2hjj+cBjwAdCCEeVrGM28Argghjjy4HVwN+GEE4s+Lqd9XZmO1+Pju3sFP+8n9QPZdtO
qeFX2rZTy25mny/HxW+Bm1GynZp2M7t+JzxhO6/Vtp0W7GamQ912atnN7NpPjH/leWd3di3Neae0
BerzTmXbKceF6rzTgO2sj00T8063nQ0a1GynZI93UoQQLgbuDCF8OoTwpuzHi2OMG4DvA08JIZye
vbdzmI9pp44rQwgXxBiXA73iLU8B/i97byFGsqkv3hhj3BVC6AwhHAD8GKgCFwBXZUaiMJocBPUH
dSewhXQznJO9VsiDs6kv/jz78duBr4QUhjiP5En9TAjh6CI0CC3SeQXwUmBX9toXgEtDCKeEEGYW
dP3mcVHNxkVHNrk6jBSKWHgebZMTbRCYDRyQ/XsIODCEcGBZziugQrKT9e/m28CrgLNDwSGqTQvB
7cBRQN2bfiXpfnlB9jAp4vqXkcbefkJHVLCddR1Pzn70cIyxbNvZrGFH9vNSbWdTP9fHZGl2M9Ow
27gg7RKXajuFc6D+t76YEu1mdp2GcRFjXJ/9vFTb2TQuKsAMSrabLXTUd2NLtZ1Ni8DtpAVYaXYz
0/B3wI3ZfO+N2Y815p11HZ8JIbxWad4p++L12byzQ8F2ynFR+pwz0yD74s3ZjzVsp3RcQclzzuw6
cmy+Xmve2eQQUplzttChMu8MIfTUP1/LdjazRzspQggvAF4GvAi4DrgihHCcuDEfAG4ghb8RYxws
4oHRpON/gCtDCMdn16sbgQOApZmOthvJFn3xybqGGONa4OwY42tJ3v79gUParUFoaVgUZz+bAfQA
38j0HRhC+FwI4aUFXL+5Ly4LIZwUY7wNuJAUCnkx8DrS93JYuzUILbIv3pL9+GrgrBDCd4BHsp+9
DXhtAddvNS6OizEOktuHbwCnQbE7P019cUGMsQ/4R+BVIYRHgZXAccBlFBQe2qThtZmG3wNvDMm7
/UzgdtK4WFiEhkxHw0Iwe0h/H3hqCGFmjHEpcAdwEMl50c5rzwohvJ+UF/oM4CTxWn1M3E/BtrOF
jhOza9UdBF3ZWwuznSNoGAohVMq0nS2cAx3ZxOlJlGM3W46LrB/uIu0Ov7kM2zmMo+S7lGc3W44L
QX1CW7jtbOFAqwL/QIl2cxgdXcDdlGg7mxaBb8p+fA0l2M3s+vuGEL5C+lvfAtwCvD2EcLCwTWXY
zmYdNwPvzHSUMu8cpi/+JtMwVLLtbHCUZD+bQXm2s1VfvDWEcFiM8XbSvLMs2yn74s+yH5dpO1uN
zfq4GCQthKEc2yn7oj7f07CdUsf5wAZKnneGEN4L3AR8LoRQL1pamu0cjj3SSSE8XjOBu2KMy2OM
vwK+AHxSvPVx4DukYjWXhxCuBA4vSccVADHGndl7ng78JiQ+EtqUfzQWDRn9mZ4NwHpgn3Zcv4We
VoviE2OMu7K3zCVN+v4IOBuIbbz2WL6Pf4wx3pq1HwM2Ul5ffDykHLy7SN79vWOMV2TabgaODG3y
oo7lHslC8CDtGldDymktZNenqS9+QtpJOD7G+F1SHu93Y4xvJVV83ggcWYKGz4YUXvcvpD74Oumh
eSlwKsnL3m4Nuy0Es0XgELACmA/UC1vdkL2n3d/JLtIO19OA3wFnhhCOyF6rT2QLtZ1j0CHHZyG2
cywaMh3V7P+F2M7hnAOZg7lG+k56KMhuClr2RX1xE2P8YuboLcx2Dnd/ZC/3Apso0G4Khh0X2f1a
D5cuzHa2cpRk194RY7wGuJZy7OZwOlYD/wVsB75GgbZzBOfAvqTJ/r4Ubzch2cWfxhj/JHPc/Ty7
/sFN7ynado6oo+h551g0ZDqKtp3DOUoWZXPOCuXYzuH6YiE8Me8s2na26ou/CiEcmGkpdM4pGG1s
1tcCRdrOVn1Rd+JdTXlzzlY63kWKXvg3Uh+UYTu/DJwC/CnpuXFe5sRbSnm2syV7pJNCeITnAPND
Vhk1u/kODCH8SfbvIdID9DiS1/CxzFtUqo4QwpGkQfkx4FtAX+bRK00DaVdufgjhKlJ/3NaO69cZ
YVH898AnQvLszwD+k2QUPkGaBD6/XRpG6Ysni75AqS++AHwcWEPu2X9KFnY1F9hV30WeLOMYF5Ai
jt4cY6yJyXdbGKYvfkkaF9KhOBhC2CfGuJk0sWhbpeERNHwB+GyMcUWM8d2kCJvXxhjvJXnY57dL
g2C3xQ8pJBfg18Ba4EUhhEOyycw62vzwzOzikhjj48B/kyZSp4QQZsUYayGFY9Yo0HaOpgNSVEcI
YREF2c7RNNT7ItNSmL1g5AXxbNK4/QoF2c06Y/g+Ktn/S+0LoO40WkJyLh5QlN2sM4ZxUZ/EFWY7
ad0XcrFboUC7OYqOIwBijL+PMV5E8baz1cLnXtLC5zbSM7VQu5k5ZraRFjh1BkhRNmvEewq1nWPR
kb2vMNs5Vg3Ze4u0F8M6BzK71UXBtnOUvljZ9N6y++I+0s74KlKUd6G2c4z3SH1dWqTtHG5c1CN5
apRjO4ezW0fEGJeVNO/cDHwuxvjqGON9JKfEPaS/+SekOeeLi7SdI7FHOClCOrbmOPHvCkCM8Xuk
zjxbvP3TwLvFvz9JGhSHxBg/XbKOi7J2hfRQXwc8N8b4DyVqeFfWfjpp16MLOCPG+NBENbRihEXx
J0lG8nTge8CnY4wnxxj/HriTxvzJcTHRcZEtAL5Ncpo8L8b44EQ1tGKEvvgEcCgpBPLrpFCrfwgh
fJFUffrmiV5zkvfIb0lRHp1iQd8WxuAsOYc0DvYmRVdcRYp0uKUEDZ8gTWZek/37kRDCISGEfyJN
ftu+4zLM4udZIYS9YtptuoaUN/n1EMKXSLvqd0z0es3jQujYnk0olpO+/+cDxwiNkCo+F2I7x6Fj
FsmJ03bbORYNQC2EcDxpZ7Qo2zncgnivbDJ5C/DxdtlNmHBf1G3nf1Gc7WzVFyeHEGZnk+lrSd9F
W+wmTHhs1ifVN1Gc7RxuXNTzhR8jObAKsZuj6DhZOhNjjGuLsp0jLHyOB6oxxo2kVLm22c3sug3j
IuYRRbLg3wLg0Rjjw/I9FGg7x6IjYzYF2c6xashs539TgO0cZUH8SGYvbqZg2zmOvijMdo5yj6yP
KbLmGlLaR2G2c4z3SH1+UYjtHKMD7VEKtp2jfCdr6z8o0nZmn78jxnhv1s9vIq2JF5L6//mkzboO
2mg7x0PX6G+xS2bgvkoKg75HvFQJKYdmB/B54MIQwu3ZZOIm4LQQwpOyG+Ud2UDR0PG8kEJq+oFj
Y4yPMEHaoOEh4PyYFf6aLCHl/d0dY7wn+3cl84h+L4TwPtKi+LvZ2z8NXBpjPC3TBECM8asTvPZk
+mIWyVCdH9u3qzDevvg74Psxxo+GVHH6JOC92SRwvNeezD0yB9gWU1j95yfwp7fSM+6+iDE+L6Sj
wi4gPcD/YCJ9MQkNf0tyWgH8E2l8vCzGuHWiGlrpqCMXPyGE+uInAnfGGJcAfxdC+CPSrum7Yoxb
JnDtluMi28Woh6t3kh6a3yJVuD42hPAMYHuM8Tsk2znZPpiMjo2k3Z9jY4xrmCCT0HAcsCHG+KMQ
wmti2mWYFOMcE0uAO7LvQr53QnYzu/5kvo/+GOMPQghteY5M8P7YQqo99QvgBCZoN7PrT6YvHo8x
fi+m0OVJ286JjAtSaO6DpBN5upik3ZyAjsWkyLT6ouOLpAKFk7KdzRpGWfisyF57kDbYzez6o46L
EEJnNj4OJtkpQggvybT8FPibouadY9BxFrCVVDCzcNs5goZtMcYbM3vRdts50rggnShCTOmkT1C0
7RyhL7bHGG8oynaOco/0Zq89TopqPpm0YC/Udo5wjwzGGH9elO0cy7gg2c6lFGg7R/lOHm769UJs
pyT7Tu4CDo2p5tYFwD/GGI8G3hXS8cVHMAnbORGmtJOClD/+TzHGf5M/zB6KO0IITyF5Jo8FPhhC
uBM4F1hRHxiTfVBMUkdvdiM+akDDLlJO2qSY4KL4N8AfZIvi7UAtxkkVcZpMX9RD27ZP4vrAhPvi
t8BzQwjdMcYtMeUpTibsbzL3yKQWoJJJ9MVpWV+sDCF8cjLjok1OzfPb8LCayOLnaSHVK9kWY/xu
TDnnk2GkcUE2LvpIO5H9IYQHSUVM+4B3Zu9tx/iYqI4NJCfJEE3hw2VryN47qUn2BMfEMSGEpwFb
Y3KwdcTJFxhrR19MapI9yftja4zx6hjjLUx+52vS98hkmcS4eDrJUXJ1ZjcnNS4m6bDZli0Gz5/M
5HaSC59ajPFnbbCbMLZxsSG7/unAjBDCv5Byud+fvbfoeedIOo4DLs7mfWXYzmE1ZO8t3HY2j4ts
EfbEgjjkaTiToR3jonDbOcI9MhRjvD6mmmy3TkYHbeiLyTLBcVHLnEaDMcbrQwhXTHZctMNuUYLt
BIgp5aTOz4GXhBDmxxg3xBivnej1J8OUclK0MCRHk05CIITwblLV5N/FdJTNxcB7SOe8XkVKZ/gL
4Jdx8uF16josaBiG0hfFe2hfTHSXZ4/ti4InEWN1ak7KQTEGHYUsfiYwLt4F/FkI4brsvX8LfCbG
+PGJXN+SDgsaWtAOp9G4F6J7al9MhD21L9rguGqXjslugqgsfCY4Lt5MXqfjVOCqGONfTVSDFR0W
NLSgHc6Bcc8t9tS+mAh7al+0Yc7ZLh1l2M6+mBWyDSEsJJ1y0htTmrEaU8ZJEUJ4B+l81huB78RU
OXoNsH8I4RpSDs/JwFtCCB8npVAcJTr4NyGEmyb7wLagw4IGoUV1Uex90XB97wtjGiaoo62LnwmO
i2Pq4yKEsAJ4xmQdNBZ0WNCQfY76gtj7okGD94UxHRYWPpMdF6Sokr+uT/6nsg4LGjIdPi5yHd4X
uQ71vrCiY4Ia3hRCuIHkVH4d8J8xxqsmqqFdVGq1th6NXAghhFeSPErvIx1ztY1U3OMPSGdN3xZj
fG9IFbV/TqpU+oPsdztJYUyT/kMt6LCgQWh5B/AC4AnjFEK4AlhGyutfS6oQ3EU6teI5wH9Jz1yY
RIiy90XD9b0vjGloh46Qinh2THTxM8lx0RXzYz4nhQUdFjRkn6U6JrLP8L7INXhfGNPRBg3nAL+Z
5KJ8MuNiZsyP+ZwUFnRY0JB9lo+LXIf3Ra5DvS+s6GiDhlOAGGPsn6iGdjJVTvd4NvDFmI5p/Cgp
r+b9McZvkzp8VgjhgJjyam4iO7Iv8ybVz5LfU3RY0FA3Tm8gVX49nhQevwi4G3gt8GDmCbyAdKTN
ohjjP8cYNwRRrXeSi0DvixzvC0Ma2qCjK9OwbZKLjsmMi7YsvgzpUNdgZEyA94XE+8KQjklqmJlp
+NFkFxxMbly0ZfFlSIe6Bh8XOd4XOVb6woKOSWqYkWm4JRpxUIBxJ0XIz8tdRgo/IaZqzT8ghRKd
BlwJ7ATeH0L4MPAqUmXWduUTmdBhQUMTaoti74sc7wuzGiarY1KLHyvjwoIOCxoEqgti74sc7wuz
OlQXPlbGhQUdFjQIfFzkeF/kqDtKDOmYjIZdbdLQVkw5KUII+2X/r3vk6zuZ3wW2hXR8FMAjwC9I
x8LcAVwBPADsBbwoxnjnVNdhQcMwuko3Tt4XDdf0vjCsQUuHlXFhQYcFDS00qYxN74uG63pfGNYx
3ceFBR0WNLTQNK3HRZMm74tck7rNsqLDgoaiUK9JEVJo9Rzgy8AhMcbnip9XgLrANwGvAc6K6ZiY
9wLdMcZL9xQdFjS00LRfjPGx0JR7G0JYAPwn8OUY4zUhhLmkEKK9Y4yfzl5/NXAoybO3cpzX9b7I
P9/7wqgGTR1WxoUFHRY0NOlRG5veFw3X9r4wqsPHhQ0dFjQ06Zn240Lo8b7I9ajbLCs6LGgoC/XT
PTIPzuMhBIB9QwhvjzF+Eeisd34IYW/gp8DzgX8LIXwEOAm4b0/SYUFDdo0G4wQ8N8Y40GScNgDf
A94WQrg2pmPH5gB7Z39LH/AvE9XgfZHjfWFLgxUdVsaFBR0WNFgYE9lneF9keF/Y0mFBQ/YZ6uPC
ig4LGnxc5Hhf5FjpCws6LGjQQDXdI4RQyf47EFgH/Dmpc/cRN8FlwPeBA4CLsvd9g3Sm7BV7ig4L
GurEGGsxL3y1bwjh7Vm7M8ZYPwViDsk4rSEZp4Uk4zTpvCbvixzvC3saLOiwMi4s6LCgAfTHBHhf
SLwv7OmwoMHKuLCgw4IG8HEh8b7IsdAXVnRY0KBB6ekeIYQzgO0xxt8FccRfCOFa4K+BvwMeJ3l7
HgO+BHw4xrhUfMacGOPWqa7DgoYWmipZ8wDgYlLO2ReB58cYN2bvuYxUoOViUmGWdwOnkc7efUdM
RVnGe90z8L6oX/cMvC9MatDUYWVcWNBhQUOTHrWx6X3RcO0z8L4wqcPHhQ0dFjQ06Zn240J8lvdF
/lnqNsuKDgsatCjNSRFCeBLwFeBM4Brgopify3oU8LYY47tCCOcBXwdWxBiPE7/fCdS9RVNahwUN
TXrOQMk4eV80XNv7wqAGbR1WxoUFHRY0iM86A8Wx6X3RcH3vC4M6tDVYGRcWdFjQID7rDHxc1D/r
DLwv6p91Bm47zWiwQJk1KXYCvwL+HXguqXjHv2avrQGODCH8EAjAjcATXp8QQmcbvUAWdFjQsJtx
CiEsaTJOy2KMq0II15OM08sy4/TauhYy4zSJG8H7Isf7wpAGQzpMjAsjOtQ1GBkT4H0h8b4wpMOC
hgz1cWFIh7oGHxc53hc5VvrCgg4LGixRaE2KEMIbQghnhJTHtIPk6fk5sAR4ZgipIgvwJNIZrsuA
Z8YYzwUOCSE8E2CyN4EFHRY0tKBunF5HMkavFq9J4/QZknFaJv6ezhjj4ES8p94XOd4XpjWo6bAy
LizosKChCbWx6X2R431hWse0HxcWdFjQ0MS0HxcC74scCzbLig4LGszQ9nSPkHJnDgS+CQwBS4Fu
4J0xxsey9xwFvJEUynJZ9rN5Mcaq+JyGf09FHRY0tND0BuBh4O4Y48YQwuxM2/kkL+pVMcYYUsGc
jwFbgUtijJtDCLcDfxljvH0C1/W+yK/rfWFUg6YOK+PCgg4LGpr0qI1N74uGa3tfGNXh48KGDgsa
mvRM+3EhPsf7Iv8cdZtlRYcFDVZpq5MiZGe2hhACKTfmdSGELuDzwEExxleK974CeBHwOWAV6QvZ
CVRilnszlXVY0CA+X9U4eV80XN/7wpgGCzqsjAsLOixoyD5bfWx6XzRo8L4wpsOIBivjQl2HBQ3Z
Z/u4yD/b+yL/bPW+sKLDgoapQFucFCHlwFxOSh+5jhQi9McxxjeK19cAfxJjvFH83geAt5C+mDNi
jA9MdR0WNDTpUTNO3hcN1/a+MKhBW4eVcWFBhwUN4jNVx6b3RcP1vS8M6tDWYGVcWNBhQYP4TB8X
+Wd6X+SfqW6zrOiwoGGqMOmaFCGE04HbgXkkT9BlpDNZzwwhnAJP5C19BPio+L0/AT5Iyr15Rhse
FOo6LGgQn9kZQrgC+HhIVWKPAgYyDQPAO4HnZprJfv590k3wE9IRNkfEVHxlIosv74v8+t4XxjRY
0GFlXFjQYUFD9nnqY9P7okGD94UxHUY0WBkX6josaMg+z8dF/nneF/nnqfeFFR0WNEw12lE4s0bK
l3lbjPFLwL3A4cClwD/DE9667wOPhRAOz35vLfDSGOOfxxgf3UN0WNBgxTh5X+R4XxjSYEiHiXFh
RIe6BiNjArwvJN4XhnRY0JChPi4M6VDX4OMix/six0pfWNBhQcNUpB1OiluB72SDHeA3wKIY438A
nSGEC7OOPxgYiDEuB4gx/m+M8X/bcH1LOixoAAPGCe8LifeFLQ1WdFgZFxZ0WNBgYUyA94XE+8KW
DgsawMa4sKLDggYfFzneFzlW+sKCDgsaphyTdlLEGLfFGLfH/CiaFwHrs/abgWNCCD8GvgXcMdnr
WdZhQUOGunHyvsjxvjCnwYQOK+PCgg4LGjAwJrLP877I8L4wp8OCBivjwoQOCxrwcSHxvsgx0RdG
dFjQMOXoatcHhVT0owbsTyrUArAJ+ABwLLAixriqXdezrENbQ4xxW9OPXgT8Pmu/GfiLzDgdBfxb
UTrA+0LifWFDgyUdoD8uLOnQ1GBpTID3hcT7woYOCxokFmyWFR1+j+R4X+R4X9jQYUHDVKRtToqY
KpXOJnnqjgsh/H3WfkeM8Tftus5U0GFBA9h4cHpf5Hhf2NJgRYeVcWFBhwUNFsYEeF9IvC9s6bCg
AWyMCys6LGjwcZHjfZFjpS8s6LCgYSrRliNI64QQngP8FrgJ+I8Y45fb9uFTTIcFDZmO2cCXSHlO
byE3TptK1OB9kWvwvjCkwYoOQ+NCXYcRDepjItPhfZHr8L4wpMOChkyH+riwosOIBh8XuQbvi1yD
lb5Q12FBw1ShbZEUGSuBS4DPxBh3tvmzp5oOCxoATgReRyrQovUA977I8b6wpcGKDivjwoIOCxos
jAnwvpB4X9jSYUED2BgXVnRY0ODjIsf7IsdKX1jQYUHDlKCtkRSOPUIIBwNvQP8Bro73RY6FvrCg
wZIOxw4+JnK8L3Ks9IUFHRY0OPbwcZHjfZFjpS8s6LCgYargTgrHcRzHcRzHcRzHcUww6SNIHcdx
HMdxHMdxHMdx2oE7KRzHcRzHcRzHcRzHMYE7KRzHcRzHcRzHcRzHMYE7KRzHcRzHcRzHcRzHMYE7
KRzHcRzHcRzHcRzHMYE7KRzHcRzHcRzHcRzHMUGXtgDHcRzHcfYcQggrgG3A9uxHvwL6ge4Y43vH
+Rk7gL2B+4BPxRj/r+l9NwMzY4wnhhAWAD/PXuoGDgKWZP/+cfba/wBRfMTdMcY3jfmPcxzHcRyn
cNxJ4TiO4zhOO6kBr4ox3l//QQjh0sl8RgjhFcD/hBBeEmO8JfvZscBcYEcI4aQY4x3AidlrpwOf
iTGeLDScAdwnf+Y4juM4jj083cNxHMdxnHZTaeeHxRi/D/wL8B7x4zcDXwW+lrULu77jOI7jOOXh
kRSO4ziO47STCvDdEEI93ePv2vS5twDnAYQQZgCvBU4BBoC7QwgXxRh3jPIZTwsh3Cn+fXWM8fI2
6XMcx3Ecpw24k8JxHMdxnHbSKt3jOW34XBkdcQ6wOMa4Mvv8O4BXAN8e5TPu93QPx3Ecx7GNOykc
x3Ecx5kKnAz8Pmu/GXh6CGF59u+9SSmsozkpHMdxHMcxjjspHMdxHMcpmonUiHjid0IILwf+Cnhx
COEA4PnAQTHGx7PXZwGPhBAOqUdXOI7jOI4zNXEnheM4juM4RVMD3hpCeI342cdijF8a4Xe+G0KQ
R5C+NMZ4awjhfcD/1B0UADHGHSGE7wNvAi4T12zW0FyTYnWM8ZyJ/UmO4ziO4xRBpVZrfoY7juM4
juM4juM4juOUjx9B6jiO4ziO4ziO4ziOCTzdw3Ecx3Gc0gkhfAh4ZYuXXhRjXF+2HsdxHMdxbODp
Ho7jOI7jOI7jOI7jmMDTPRzHcRzHcRzHcRzHMYE7KRzHcRzHcRzHcRzHMYE7KRzHcRzHcRzHcRzH
MYE7KRzHcRzHcRzHcRzHMYE7KRzHcRzHcRzHcRzHMcH/B0hOJ9U4UtDGAAAAAElFTkSuQmCC
"
/>

</div>
</div>
</div>

  </div>
</div>
<div class="cell border-box-sizing text_cell rendered">
  <div class="prompt input_prompt"></div>
  <div class="inner_cell">
    <div class="text_cell_render border-box-sizing rendered_html">
      <p>
        Oh my, outliers! If the data are to be trusted, there's at least one
        flight every day that is over 500 minutes (8 hours) late in arriving. In
        the most extreme case, a flight scheduled on 2014-06-19 appears to have
        arrived 1800 minutes (30 hours) late.
      </p>
      <p>
        Whether this information is accurate or not requires some fact checking
        against other historical sources. For now, we can turn off the fliers to
        get a better view of the interquartile range.
      </p>
    </div>
  </div>
</div>
<div class="cell border-box-sizing code_cell rendered">
  <div class="input">
    <div class="prompt input_prompt">In&nbsp;[46]:</div>
    <div class="inner_cell">
      <div class="input_area">
        <div class="highlight hl-ipython3">
          <pre><span></span><span class="n">fig</span><span class="p">,</span> <span class="n">ax</span> <span class="o">=</span> <span class="n">plt</span><span class="o">.</span><span class="n">subplots</span><span class="p">(</span><span class="n">figsize</span><span class="o">=</span><span class="p">(</span><span class="mi">18</span><span class="p">,</span><span class="mi">10</span><span class="p">))</span>
<span class="n">sns</span><span class="o">.</span><span class="n">boxplot</span><span class="p">(</span><span class="n">df</span><span class="o">.</span><span class="n">ARR_DELAY_NEW</span><span class="p">,</span> <span class="n">df</span><span class="o">.</span><span class="n">FL_DATE</span><span class="p">,</span> <span class="n">ax</span><span class="o">=</span><span class="n">ax</span><span class="p">,</span> <span class="n">showfliers</span><span class="o">=</span><span class="kc">False</span><span class="p">)</span>
<span class="n">fig</span><span class="o">.</span><span class="n">autofmt_xdate</span><span class="p">()</span>
</pre>
        </div>
      </div>
    </div>
  </div>

  <div class="output_wrapper">
    <div class="output">
      <div class="output_area">
        <div class="prompt"></div>

        <div class="output_png output_subarea">
          <img
            src="data:image/png;base64,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
0GMH9+WBD77n5DEPPrDmDJvOPqfvPDn/3L5jer1ejt7zxRz4vX/XJ+DR+d+X1do0noz3+bvdkcPp
5Sl9Mxy650v55LUn35pw7tjRzK0hw9im8Yz1yXD8yOH08uS+Y3q9Xg7c86V84Ld/8rFjjh3N8bV8
HZJs2jSeTX1yHDtyOFvm+ue478BdueH9u086fujQbA49uPjfBxaz9exOtm7d1neebZ1nLDpu38G7
Ttoj4oEHZ/OVQ6vPkCRP2NrJOWefnGPfwbvyNef3z/GlmbvyWze/7aTjX35wNg88tPoc55zVybl9
Mnxp5q48Y/viX4u7Z+/KOz92zWOO3X94Nvc/NLvqDEly3lnbct6Zj81x9+xdufSJX7PomLvu/0Ku
+cS7Tjo+e/j+zB6+f9UZtp15XradeV7feS69qH+O+Z+Jvpif/NDVjzl+9PjRHFvj98j4pvFs3vTY
75HDRw/nojNOvlacmOEnbvr1k84dO34sR9eQY/Om8Yz3+XPk8NGHl89x4//1uAzH15Th0RyP/1n5
SC46+Y/Tvsbm5tb8s/+6K6U8N8m/q7W+YOHzK5Mct2ElAAAAjIZhWxHx10m+rpRyaZIvJvmhJD8y
0EQAAADAuhmqPSJqrUeT/Oskf5rkk0neW2u1USUAAACMiKF6awYAAAAw2oZqRQQAAAAw2hQRAAAA
QGsUEUCSpJSywpvtAPAI106A1XPtZEMUEaWU8YVfB/r/W0r5J6WUk2/a3m6Gby+lnHwT3g2olPLz
pZSnDTrHMCil/HKSk2+IzoY2DNfOYbhuLuRw7Vzg2vko1076ce18TA7XzgWunY9y7SQZ8SKilPLa
Usr/TPKzA87xqlLKbUl+NckfD6IBXMhwa5K3JPmjUsqZbWc4IcsPlFK2D3D+V5dSppJ8a5Ivl1LG
BpjlraWU5w1w/stLKXuS/GiSyweVYyHLi0opFw0yw0KOrxv0X95KKV9fStk6wPkHfu0chuvmCTlc
O+Pa+bj5XTtPzuHa6dr5+ByunXHtfNz8rp2PzTDw6+ZCjoFcO0e2iCilfEOSn0xyY5LvKaV8Ta31
eJvtdCllrJTysiSvS/JjtdYfSLI1yY8/cr6lHC9M8hNJfrLW+pIkT03y/Dbm7pPlLUn+a5IfHtD8
353kd5P8m1rr5bXW2Vpr67eOKaV8Wynlr5I8K0m37b8olFI2l1J+LPOvxX9ba31Gki+UUr6pzRwL
WX6glPLpJD+d5HdKKd/YdoaFHC8rpdyR5P9v78yjLamqO/w9uhlkUERUkEFFw0bRJmAgKgita6Gi
OKDRSIOCjcYhoiIiaAZURAhDEAc0EpdzHJiNY8QBAyjIICriBsKogAwNqNDdQPfLH+dUV/X1jbem
/fr+vrV69Xv31qv63n777nvOvlWnPgic2segxcz2MrPbgH8Dvm5mm/bgEKF29l4387FUO8vj74pq
p2rnxB6qnfRfO6OMOfOxVDvL42vciWrnBA69183s0WvtXKMaEWa2UfG1u18FHACcBFwFvC0/vrIr
j1xofgkc4O4/y0+fDLys8nyrDpnvu/tu7n6BmW0M3ARsaGYbtnX8CXyKXFsKfCE9ZH+Tn2v1zXEg
L84HLgG2y88dYWYv6SoWld91O+CL7r6Pu18HrOjo+EVuPgSc4e67u/vFeQD1py4cBnweA/wDsNjd
XwjMB/p4Q9gEeAOwyN33Be4A3mdm23bosB6wD7C/u78M+D3wTjPbsYNjzyu+zrXztXRcO6sOwG9I
cei0bk7g8aMRr53VvLgAuIjRrZ3zYFXtPEe1c5XHqNfOVfnf17izcOhzzFn1yIz6uLOaF6M+7izy
U+PO0qH3upk9equdBWtMI8LMjgAuN7PjzOzA/PBv3X0JcBbwJDPbI287b5LdNOlxvJnt7+7XAzdW
NnkS8NO8bSuFcCAWB7j7g2Y2z8w2A74F3APsD5yYC0ErDDQAijfiecCfScm+d36uzYZMNRZvyA+/
Ffi8pVMGNyZ1RE8ws+1a9Kg2pwD2Ah7Mz30UONLMdjGzdVp0GMyLe3JerJUHUE8gnTbY6nWtA02y
FcB6wGb5+5XA5ma2eZcNKmCMVA+Lv89XgVcCL7YWTycdmOgtA7YFiq748aTXy/Pym0VbDkeR8u/R
FRfvsnZWHB6TH7rJ3Tutm5N4LM+Pd107q3EucrLr2vkXeUH6tLfr2lk0AIrf9fl0XztXywt3vzM/
3nXtrObFGLA2/dTOqkfxqWrXtbM60VtGmmR1XTsPB87L470D8sOdjjsrDieY2aI+xpwDHseb2Wvz
uHOtHmpnNS/6GndWY7E4P9xH7aw2qKCfcWc1P1/b47iz2vTpZdw54NDLmDN7PLw4Rl+1s8oa0Ygw
s+cBLwL2BL4DHGNmCyovvquAH5NOV8PdV7TxpjDg8W3geDPbIR+veKFvBlybPRovhBPE4tjCwd1v
A17s7otIXfvHAls17ZA9Vpv05sfWBh4OfDm7bW5mJ5nZXi05DMbiKDPbyd0vAd5OOnXxCGA/0t/l
CS15VGNxUH74DOCFZnYacGt+7C3AopYcJsqLBe6+grIOfBnYDdr7BGcgFvu7+13Ax4FXmtntwM3A
AuAoWjyNc8BjUfb4FXCApU71M4BLSXmxRUsOq0308pvwWcBfmdk67n4tcBnwOFKDounjr2tm7yVd
p/l0YKfKc0VO/IYWa+cEDjvm4xQNgPl507br5mQeK81srOPaOdgAWCsPjjaig9o5WV7kOPyC9Cnv
4o5q50TNkNPpqHZOlhcVikFrF7VzsEl2D/Axuq+dgx7zgSvotnZWJ3oH5ofPprvauamZfZ70ux4E
XAy81cy2rNSntmvnoMNFwDuyQ5djzoli8bbssbLj2rlaMyQ/tjbd1c6JYvEmM3uCu19KGnd2VTur
sXh9frjL2jlRfhZ5sYI02YVuamc1FsV4r9PaOeCwL7CEjsec2eMw4ELgJDMrFgrtrHZOxJxuRFQ6
V+sAv3D36939R8BHgWMrm94HnEZaIOZDZnY88MSOPI4BcPcH8jZPA863xPutoWuCZuKQuTf7LAHu
BB7ZxPEHXCaa9O7o7g/mTR5BGtS9HHgx4A0ffyZ/j4+7+8/z13cAd9NNLI62dD3cL0gd+g3c/Zjs
dRHwZGuwGzqT10g+XQ7Sp7/3WLrOtO1G3XdJnwbs4O6nk66pPd3d30RaRflu4MlNO0zi8e+WTof7
FCkGXyK9MR4JPJPULW/y+H8x0cuTvJXADcAmQLGQ1I/zNm18mvYg6ZOqpwI/A55rZtvk54oBa6u1
cxqHam62Ujdn6pFd7sn/t1I7J2sA5CbyOOlv8nBarJ2ZCWNRTGLc/ZTczG2tdk72GslP3wj8kZZr
Z2bSvMiv2eLU5tZq50TNkHzs5e5+NnAOHdTOKTx+D3wNWAZ8kXZr52QNgE1Jg/pN6aZ23gd8z91f
nZtz5+bjbzmwTZu1c0qHtsecM/XILm3XzsmaIVvncecY3dTOyWKxBawad7ZdOyeKxZvNbPPs0vq4
MzNdfhbzgTZr50SxKJp1Z9DBuHMSh0NIZyB8mvT7t1o3Kx6fAXYB/p70vvHS3Ki7lu5q518wpxsR
le7u+sAmllcdzS+wzc3s1fn7laQ3yQWk7t8duevTqYeZPZmUfB8EvgLclTtznTmQPl3bxMxOJMXj
kiaOD1NOek8GPmypQ7828DnSi/7DpEHe7k05wLSxeEwlFvQQi48CRwO3UHbnn5RPj3oE8GDxaXAT
zCIvIJ05tNjdxysD7NpMEosfkvKi2jBcYWaPdPc/kQYOja7eO4XHR4F/d/cb3P1dpDNlFrn7r0md
8k2a9GCCyQ3p9FmA/wVuA/Y0s63yYOUPtDCxyHXxane/D/g6abC0i5mt6+7jlk6dHKfd2jmpA6Qz
M8xsa1qqmzPxKGKRfVqpF5mpJr3rkfL287RYO2FGf5Ox/H+nsQCKxtDVpAbiZm3WTphRXhQDtVZq
Z2aiWFQntGO0XDun8NgGwN1/5e6H0n7tnGhy82vS5OYS0vtqq7UzN1+WkiYxBQ+Rzpa5pbJNa7Vz
Jg55u1Zr50w98rZt1otJGwC5bs2n5do5TSxuHti261hcSfqE+3eks7VbrZ0zfI0U8882a+dkeVGc
kTNO+7Vzspq1jbtf19GYE9JaHCe5+6vc/UpS4+GXpN/5u6Rx5/PbHndOxJxqRFi65cuCyvdjAO5+
JilgL65sfhzwrsr3x5L++Fu5+3Edexyavx4jvXH/AdjV3T/WocMh+eunkT69mA8sdPf/G9ZhkCkm
vceSiuAewJnAce6+s7ufDFzO6tczzpph8yIP8r9Kao48x92vqeNRZYpYfBh4POlUxS+RTon6mJmd
QlrR+aI6x635GrmAdMbGvMqkvTYzaIbsTcqDDUhnSZxIOlvh4qYcpvH4MGnA8pr8/a1mtpWZfYI0
wG30k5NJJjd/Y2YP8/SJ0dmkaxi/ZGankj4Zv6zOMQfzouKyLA8arif9/XcHnlLxhLSScu3aWcNh
XVKjpnbdHNYDGDezHUifcDZeO/PxJ5v0PiwPGC8Gjm6zdlZcpopFUTu/Rgu1Mx9/oljsbGbr5QHz
OaS/RWu1s+IyVX4WA+cLaaF25mNMlhfF9bt3kJpUrdXOKTx2rjYN3f22tmrnFJObHYB73P1u0qVt
rdZOL88Mqi6y9yjgdne/qboNLdXOmThk1qPF2jlTj1w7v04LtXOaSe+tuV5cRMu1cxaxaK12TvMa
udPTWTJnky7RaK12zvA1UowvWqmdM2yS3U6LtXOav8dtxQNt1s3KMZa7+69znA8kzYm3IMV/d9IH
cmvRYO2cKfOn36R/chH7Aum05V9WnhqzdE3LcuAjwNvN7NI8YLgQ2M3MNsovhoNzQvTh8RxLp7/c
C2zv7rcyJA04/B+wr+fFtupg6Rq8K9z9l/n7sdzVPNPM3kOa9J6eNz8OONLdd8s+ALj7F2ocv04s
1iUVo329gU8IhojF4cBZ7v4BS6s47wQclgd5wxy/zmtkfWCpp9PgPzLM8QdcZh0Ld3+OpVts7U96
g372sLGo4fFOUmMK4BOk/HiRu9/flENBdXJjZsXkxoHL3f1q4HAzeznpk89D3P3PQx5/wrzIn0YU
p5bPI705foW0cvT2ZvZ0YJm7n0aqnXViUMfhbtInONu7+y3UoIbHAmCJu3/TzF7j6dOCWswyL64G
Lst/i+q2jdfOGf5N7nX3b5hZK+8jBdO8Rv5MWgvqB8Bf00LtnGEs7nP3Mz2dZtx47SyYKi9Ip9Fe
Q7rTzXxaqJ3TePyWdIZZMbE4hbQoYKO1c5rJzQ35uWvosHaa2bycH1uSahVm9oLs8j3gbXXGnTUc
XgjcT1qkspPaOYXHUnc/L9eLxmvnVHlBulMHni7/XEXbtXOKWCxz9x+3VTuneY3cmJ+7j3SG8s6k
SXmrtXOK18gKdz+3rdo5k7wg1c5raah2zvLvcdPAjzdSNyfyqJL/Jr8AHu9pDaz9gY+7+3bAIZZu
/7sNNWrnbJkTjQjS9dyfcPdPVx/Mb3zLzexJpA7j9sA/mdnlwEuAG4oEqNuEqOlxY36x3R7A4UHS
NWJDM+Sk93zg2XnSuwwYd6+9cFKdWBSnoS2rIzBkLC4AdjWzDd39z56uGax7el6d10itoldQIxa7
5VjcbGbH1s2LhhqX+9Z8QxpmcvNUS+uHLHX30z1d/12XqfKCnBd3kT5RvNfMriEtHnoX8I68bd38
GNZhCakJspKB03z78Mjb1hpID5kXTzGzpwL3e2qireX1F/VqIha1BtI1XyP3u/sZ7n4x9T/Bqv0a
qUuNvHgaqRlyRq6dtfKiZlNmaZ7w7VtnAFtzcjPu7v/TYe1cko+/B7C2mX2KdG31e/O2dcedwzos
AI7IY76uauekHnnb1mvnYF7kidaqSa+Vl8zUoYm8aL12TvEaWenu3/e0RtrP63jQQCzqMmRejOfG
0Ap3/76ZHVMnL5qoWdSsmzP1APB0iUjBucALzGwTd1/i7ufUcRiGkI2ICYrFdqS7DGBm7yKtRvwz
T7eBOQJ4N+k+qCeSLj14I/BDr38JRu8eERwmoJdJ7xoYizqDtTUyFg0MEup6FI3LWp8oTuPQ2uRm
iLw4BHi9mX0nb/tO4AR3P3ouO0TyGKCJxtCsJ5traiyGYU2NRQPNqaY86n6K1svkZsi8WEy5bsYz
gbpeq+4AAA3HSURBVBPd/c1z2SGSxwBNNABmPb5YU2MxDGtqLII0p5o4+2BG9dvz4rFmtgXp7iE3
erosuBfCNSLM7GDS/UvPA07ztCLzLcBjzexs0nU1OwMHmdnRpMsdtq0E8Xwzu7Dum3IEjwgO2aP3
Sa9isZqDYhHMI8LkZsi8eEqRF2Z2A/D0Ok2YCA7BPJQXpYdiUXr0HosoHhEmN3XzgnR2yD8WA/y5
6hDMQ3lReigWpUeEWPTuUMPjQDP7MalxvB/wOXc/sY5HXcbGxxu/rfDQmNkrSN2h95BuEbWUtKDG
s0n3Yr7E3Q+ztFL1uaQVQL+Rf3Ye6ZSj2r9QBI8IDnlfBwPPA1YVHzM7BriOdI39baRVd+eT7gbx
LOBr1e6a1TyVWLFYzUGxCOZR18HSoplr1WwA1MmL+V7eJnNoIjgE81BelB6KRenReyyieDTgsDdw
fs0GQJ28WMfL22QOTQSHYB7Ki9JDsSg9IsSid4eGPHYB3N3vrePRBNHumvG3wCmebnP4AdJ1Lu91
96+SgrqumW3m6TqXC8m3vMtdoeJe62uKR+8Oufi8jrSa6g6k09i3Bq4AFgHX5I7e/qRbwWzt7p90
9yVWWQG37mQTxaKKYhHIo6bD/Hz8pXUnFdTLi0YmWEEcQngoL0oUi5IosYjgUdNhnezwzboDeurl
RSMTrCAOITyUFyWKRUmEWERwaMBj7exxsQdoQkCQRoSV95O9jnSqCJ5WQf4G6bSf3YDjgQeA95rZ
vwKvJK142tR15SE8IjhU6HXSq1iUKBZhPXqd3ETIiwgOkTwyI58XFRSLkt6bIYE8ep3cRMiLCA6R
PDIjnxcVFIuS3pshQRzqejzYoEcj9NKIMLNH5/+LznrxieTpwFJLt14CuBX4AemWKpcBxwBXAQ8D
9nT3y+e6RwSHCZx6KT6KxWrHVSwCe4xyXkRwiOQx4DSyeTGBk2JROvVes6J4jHJeRHCI5DHgNLJ5
MYGTYlE6jWzNiurRNJ2tEWHpNOj1gc8AW7n7rpXHx4BC5EDgNcALPd1i5TBgQ3c/ck3xiOAw4PNo
d7/DBq6DNbNHAZ8DPuPuZ5vZI0in+mzg7sfl518FPJ7Unbt5iGMrFuUxFIugHqOeFxEcInlUfEY6
LwZ8FIvSp/eaFcVj1PMigkMkj4rPSOfFgI9iUfqMdM2K6NE2nd01I3di7jMzgE3N7K3ufgowrwiw
mW0AfA/YHfi0mb0f2Am4ck3yiOAwWHyAXd39oYHiswQ4E3iLmZ3j6XZd6wMb5N/jLuBTdTwUixLF
IpZHBIe8j97zIoJDFA/lRYliURIlFhE8IjjkffSeFxEcongoL0oUi5IIsYjgEMmjSzq5NMPMxvK/
zYE/AG8gBfCRlUQ/CjgL2Aw4NG/3ZdJ9V49ZUzwiOEAqPl4uNLWpmb01fz3P3Ys7K6xPKj63kIrP
FqTi08g1RopFiWIRzyOCQ4S8iOAQyUN5UaJYlESIRRSPCA4R8iKCQyQP5UWJYlESIRYRHCJ5dElr
l2aY2UJgmbv/zCq3xzOzc4B/BA4H7iN1be4ATgX+1d2vrexjfXe/f657RHAY8BnLX24GHEG6/usU
YHd3vztvcxRpQZQjSAuhvAvYjXRf2oM9LYIyzLEXolgUx16IYhHSY9TzIoJDJI/KvkY6LwZ8FIty
X73XrCgeo54XERwieVT2NdJ5MeCjWJT7GumaFdGjaxpvRJjZRsDngecCZwOHennf0m2Bt7j7IWb2
UuBLwA3uvqDy8/OAouszpz0iOFT2tZAei49isdrxFYuAHn07RMiLCA6RPPK+FjLieVHZ10IUi2Jf
C1HtDOEQIS8iOETyyPtayIjnRWVfC1Esin0tZMRrVjSPPmljjYgHgB8B/wnsSlow4z/yc7cATzaz
/wYMOA9Y1b0xs3kNdnMiePTuMFh8zOzqgeJznbv/zsy+Tyo+L8rFZ1HhQS4+NRNdsShRLAJ5RHDI
9J4XQRxCeCgvShSLkiixiOARwSHTe14EcQjhobwoUSxKIsQigkMkjwg0skaEmb3OzBZauq5oOalj
cy5wNfAMs7QKCrAR6R6n1wHPcPeXAFuZ2TMA6iZ6BI8IDgMUxWc/UrF5VeW5avE5gVR8rqv8LvPc
fcWwHVDFokSxCO0x0nkRwSGSR4WRzosBFIuSCDUrisdI50UEh0geFUY6LwZQLEpGumYF9eidoS/N
sHQty+bAfwErgWuBDYF3uPsdeZttgQNIp50clR/b2N3vqexnte/nokcEhwGf1wE3AVe4+91mtl72
2pfUCT3R3d3SAjUfBO4H/tnd/2RmlwL/4O6XDnlsxaI8tmIR1GPU8yKCQySPyn5GOi8GfBSLcj+9
16woHqOeFxEcInlU9jPSeTHgo1iU+xnpmhXRIxpDNSIs39PUzIx0rcp+ZjYf+AjwOHd/RWXbfYA9
gZOA35GC/gAw5vlamGGJ4BHBIe+79+KjWKzmoFgE8wji0HteRHAI5qG8KPetWJT77j0WUTyCOPSe
FxEcgnkoL8p9KxblviPEoneHSB6RmVUjwtI1KR8iXdLxHdLpPH/n7gdUnr8FeLW7n1f5ufcBB5GC
v9Ddr6ojHcEjgkNln70WH8ViteMrFgE9+naIkBcRHCJ55H2OfF5U9qlYlPvsvWZF8ejbIUJeRHCI
5JH3OfJ5UdmnYlHuc+RrVjSP6Mx4jQgz2wO4FNiY1NE5inTP0uea2S6w6jqi9wMfqPzcq4F/Il0L
8/QGCnHvHhEc8v7mmdkxwNGWVl7dFngoH/8h4B3ArtmX/PhZpCT/LunWL9t4Wuxk2AKoWJQOikUw
jyAOvedFBIdgHsqLcn+KRbm/3mMRxSOIQ+95EcEhmIfyotyfYlHuL0IseneI5DFXmM1ileOk61fe
4u6nAr8GnggcCXwSVnXdzgLuMLMn5p+7DdjL3d/g7rc34BzBo3eHKMUHxaKKYhHII4JDpve8COIQ
wkN5UaJYlESJRQSPCA6Z3vMiiEMID+VFiWJREiEWERwiecwlZtOI+DlwWk5ogPOBrd39s8A8M3t7
Du6WwEPufj2Au//E3X/SoHMEjwgOvRefjGJRoljE8ojgADHyIoJDFA/lRYliURIlFhE8IjhAjLyI
4BDFQ3lRoliURIhFBIdIHnOGGTci3H2puy/z8jYuewJ35q8XA08xs28BXwEua1YzlkcEB2IUH8Wi
gmIRziOCQ4i8iOAQyEN5UaJYlISIRRCPCA4h8iKCQyAP5UWJYlESIRYRHCJ5zBnmz/YHLC20MQ48
lrQ4CsAfgfcB2wM3uPvvGjMM7NGng7svHXhoT+BX+evFwBtz8dkW+HQbDlUUixLFIoZHBIcqo16z
ongoL0oUi5IosYjgEcGhSoS6FcGhbw/lRYliURIhFhEcInnMJWbdiPC0Auh6pI7bAjM7OX99sLuf
37RgZI8IDlHeHBWLEsUilkcEB4iRFxEcongoL0oUi5IosYjgEcEBYuRFBIcoHsqLEsWiJEIsIjhE
8pgLzOr2nQVm9izgAuBC4LPu/pmmxeaKRxCH9YBTSdccHURZfP7YsYdiUXooFoE8Ijhkjwh50btD
FA/lxWoOikXpECUWvXtEcMgeEfKid4coHsqL1RwUi9Kh91hEcIjkEZ1ZnxGRuRn4Z+AEd3+gQZ+5
6BHBYUdgP9KCKL29OaJYVFEsYnlEcIAYeRHBIYqH8qJEsSiJEosIHhEcIEZeRHCI4qG8KFEsSiLE
IoJDJI/QDHVGhIiFmW0JvI7+3xx7R7EoiRKLCB4RHEQ8lBclikVJlFhE8IjgIOKhvChRLEoixCKC
QySP6KgRIYQQQgghhBBCiM6Y8e07hRBCCCGEEEIIIeqiRoQQQgghhBBCCCE6Q40IIYQQQgghhBBC
dIYaEUIIIYQQQgghhOgMNSKEEEIIIYQQQgjRGWpECCGEEEIIIYQQojPm9y0ghBBCiLmFmd0ALAWW
5Yd+BNwLbOjuh81yH8uBDYArgX9z958ObHcRsI6772hmjwLOzU9tCDwOuDp//6383LcBr+ziCnc/
cMa/nBBCCCFaR40IIYQQQsyWceCV7v6b4gEzO7LOPsxsH+DbZvYCd784P7Y98AhguZnt5O6XATvm
5/YATnD3nSsOC4Erq48JIYQQIh66NEMIIYQQwzDW5M7c/SzgU8C7Kw8vBr4AfDF/3drxhRBCCNEd
OiNCCCGEELNlDDjdzIpLMw5vaL8XAy8FMLO1gUXALsBDwBVmdqi7L59mH081s8sr35/h7h9qyE8I
IYQQDaBGhBBCCCFmy0SXZjyrgf1Wz3LYG/itu9+c938ZsA/w1Wn28RtdmiGEEELERo0IIYQQQkRh
Z+BX+evFwNPM7Pr8/QakS0qna0QIIYQQIjhqRAghhBCiCYZZs2HVz5jZy4A3A883s82A3YHHuft9
+fl1gVvNbKviLAkhhBBCzE3UiBBCCCFEE4wDbzKz11Qe+6C7nzrFz5xuZtXbd+7l7j83s/cA3y6a
EADuvtzMzgIOBI6qHHPQYXCNiN+7+97D/UpCCCGEaIOx8fHB93AhhBBCCCGEEEKIdtDtO4UQQggh
hBBCCNEZujRDCCGEEK1gZv8CvGKCp/Z09zu79hFCCCFEDHRphhBCCCGEEEIIITpDl2YIIYQQQggh
hBCiM9SIEEIIIYQQQgghRGeoESGEEEIIIYQQQojOUCNCCCGEEEIIIYQQnaFGhBBCCCGEEEIIITrj
/wFxh+E34aYCngAAAABJRU5ErkJggg==
"
/>

</div>
</div>
</div>

  </div>
</div>
<div class="cell border-box-sizing text_cell rendered">
  <div class="prompt input_prompt"></div>
  <div class="inner_cell">
    <div class="text_cell_render border-box-sizing rendered_html">
      <p>
        We see that the median arrival delay on most days is zero (or better
        than zero: this data column counts early arrivals as zeros). Some days
        see greater skew toward longer delays than others, particularly over the
        five day periods of Sunday, 2014-06-08 through Friday, 2014-06-13 and
        Monday, 2014-06-23 through Friday, 2014-06-27. There's also another
        period of elongation from Wednesday, 2014-06-18 through Thursday,
        2014-06-19. These might relate to weather patterns during those weeks or
        an increase in number of passengers (e.g., summer vacations). Further
        study and sources of data are required to test these hypotheses.
      </p>
    </div>
  </div>
</div>
<div class="cell border-box-sizing code_cell rendered">
  <div class="input">
    <div class="prompt input_prompt">In&nbsp;[47]:</div>
    <div class="inner_cell">
      <div class="input_area">
        <div class="highlight hl-ipython3">
          <pre><span></span><span class="err">!</span><span class="n">cal</span> <span class="mi">6</span> <span class="mi">2014</span>
</pre>
        </div>
      </div>
    </div>
  </div>

  <div class="output_wrapper">
    <div class="output">
      <div class="output_area">
        <div class="prompt"></div>

        <div class="output_subarea output_stream output_stdout output_text">
          <pre>
     June 2014

Su Mo Tu We Th Fr Sa  
 1 2 3 4 5 6 7  
 8 9 10 11 12 13 14  
15 16 17 18 19 20 21  
22 23 24 25 26 27 28  
29 30

</pre
          >
        </div>
      </div>
    </div>
  </div>
</div>
<div class="cell border-box-sizing text_cell rendered">
  <div class="prompt input_prompt"></div>
  <div class="inner_cell">
    <div class="text_cell_render border-box-sizing rendered_html">
      <h2 id="Going-Further">
        Going Further<a class="anchor-link" href="#Going-Further">&#182;</a>
      </h2>
      <p>
        If you wish to take this exploration further, here are some questions
        you might consider addressing with additional thinking and data.
      </p>
      <ul>
        <li>
          How accurately can a model predict if a flight will be delayed or not
          using simple features like origin, destination, day of the week, etc.?
        </li>
        <li>
          What factors (e.g., U.S. weather) help explain the greater median
          arrival delay and dispersion from 2014-06-08 to 2014-06-13?
        </li>
        <li>
          How do the results above contrast with the results from applying the
          same analyses to data from June, 2001? June, 2002?
        </li>
      </ul>
    </div>
  </div>
</div>
