---
title: This is My Blog on Docker + IPython
date: 2014-07-13
template: notebook.mako
excerpt: Late last year, I decided to refresh my blog with a more responsive design. In doing so, I looked for ways to simplify my <a href="http://www.blogofile.com/">blogofile</a> setup. I looked at <a href="http://wintersmith.io/">Wintersmith</a>, <a href="http://blog.getpelican.com/">Pelican</a>, and <a href="http://pygreen.neoname.eu/">PyGreen</a> but in the end decided to roll my own: five <a href="http://www.makotemplates.org/">Mako</a> templates, 170 lines of Python, and my posts in <a href="http://daringfireball.net/projects/markdown/">Markdown</a>. I was pleased. Mostly. Two aspects of my generator nagged me, both of which I corrected this past weekend.
---

<div class="cell border-box-sizing text_cell rendered" id="cell-id=ad408e25"><div class="prompt input_prompt">
</div><div class="inner_cell">
<div class="text_cell_render border-box-sizing rendered_html">
<p>Late last year, I decided to refresh my blog with a more responsive design. In doing so, I looked for ways to simplify my <a href="http://www.blogofile.com/">blogofile</a> setup. I looked at <a href="http://wintersmith.io/">Wintersmith</a>, <a href="http://blog.getpelican.com/">Pelican</a>, and <a href="http://pygreen.neoname.eu/">PyGreen</a> but in the end decided to roll my own: five <a href="http://www.makotemplates.org/">Mako</a> templates, 170 lines of Python, and my posts in <a href="http://daringfireball.net/projects/markdown/">Markdown</a>. I was pleased. Mostly. Two aspects of my generator nagged me, both of which I corrected this past weekend.</p>
</div>
</div>
</div>
<div class="cell border-box-sizing text_cell rendered" id="cell-id=01280fcc"><div class="prompt input_prompt">
</div><div class="inner_cell">
<div class="text_cell_render border-box-sizing rendered_html">
<h2 id="Dockerize-It">Dockerize It<a class="anchor-link" href="#Dockerize-It">¶</a></h2><p>First, my simple script had not-so-simple dependencies: the Mako, Markdown, and <a href="http://pygments.org/">Pygments</a> Python packages; a local webserver to preview the rendered site; and rsync to upload the generated site to my webhost. Originally, I setup my local box with all of these, choosing to "pay-later" should I get a new computer, have to restore my box, want to post from another machine, etc. Now eight months on, I decided to pay-down this technical debt by creating a <a href="https://docker.com">Docker</a> image that packages everything together using a simple Dockerfile:</p>
<div class="highlight"><pre><span></span>FROM<span class="w"> </span>ubuntu:14.04

MAINTAINER<span class="w"> </span>Peter<span class="w"> </span>Parente<span class="w"> </span>&lt;parente@cs.unc.edu&gt;

RUN<span class="w"> </span>apt-get<span class="w"> </span>update
RUN<span class="w"> </span>apt-get<span class="w"> </span>-yq<span class="w"> </span>install<span class="w"> </span>python-pip<span class="w"> </span>openssh-client<span class="w"> </span>rsync
RUN<span class="w"> </span>pip<span class="w"> </span>install<span class="w"> </span><span class="nv">Mako</span><span class="o">==</span><span class="m">0</span>.9.1<span class="w"> </span><span class="nv">Markdown</span><span class="o">==</span><span class="m">2</span>.4<span class="w"> </span><span class="nv">Pygments</span><span class="o">==</span><span class="m">1</span>.6

ADD<span class="w"> </span>.<span class="w"> </span>/srv/blog
WORKDIR<span class="w"> </span>/srv/blog

</pre></div>
<p>I drive the build and use of the image from a convenient <a href="https://github.com/parente/blog/blob/a164528fe14092d9d9147e2747733c77ac7ded94/Makefile">Makefile</a> in my blog git repo.</p>
<div class="highlight"><pre><span></span><span class="c1"># build the docker image once</span>
make<span class="w"> </span>build

<span class="c1"># render my blog posts acessbile via a contiainer-host mount</span>
<span class="c1"># then run a Python SimpleHTTPServer to view the results locally</span>
make<span class="w"> </span>render

<span class="c1"># render and rsync the content to my webhost</span>
make<span class="w"> </span>publish

</pre></div>
<p>Now rendering, previewing, and uploading my blog requires Docker and, optionally, make. That's it.</p>
</div>
</div>
</div>
<div class="cell border-box-sizing text_cell rendered" id="cell-id=8568a092"><div class="prompt input_prompt">
</div><div class="inner_cell">
<div class="text_cell_render border-box-sizing rendered_html">
<h2 id="IPythonize-It">IPythonize It<a class="anchor-link" href="#IPythonize-It">¶</a></h2>
</div>
</div>
</div>
<div class="cell border-box-sizing text_cell rendered" id="cell-id=a400450e"><div class="prompt input_prompt">
</div><div class="inner_cell">
<div class="text_cell_render border-box-sizing rendered_html">
<p>Second, I felt both liberated and limited by Markdown-only postings. I say liberated because writing in Markdown beat the heck out of writing pure HTML or using some WYSIWYG editor, especially for postings laden with code. I say limited because I missed the richness of explanation available in another tool I'd been using daily for over a year now, <a href="http://ipython.org">IPython Notebook</a>. To quiesce the latter feeling, I decided to <a href="https://www.google.com/#q=blogging+with+ipython">jump on the bandwagon</a> and support both pure Markdown files and IPython Notebooks as blog posts.</p>
<p>The addition of a couple dependencies in my <a href="https://github.com/parente/blog/blob/a164528fe14092d9d9147e2747733c77ac7ded94/Dockerfile">Dockerfile</a>, the ballooning of my generator code to a <em>massive</em> 250 lines of Python, and the creation of a new template and stylesheet enabled the blog post you see before you.</p>
<p>And now, an amazing demonstration of IPython-powered posts ...</p>
</div>
</div>
</div>
<div class="cell border-box-sizing text_cell rendered" id="cell-id=c393d8de"><div class="prompt input_prompt">
</div><div class="inner_cell">
<div class="text_cell_render border-box-sizing rendered_html">
<h3 id="HOWTO:-xkcd-matplotlib-plots">HOWTO: xkcd matplotlib plots<a class="anchor-link" href="#HOWTO:-xkcd-matplotlib-plots">¶</a></h3>
</div>
</div>
</div>
<div class="cell border-box-sizing text_cell rendered" id="cell-id=e42050d9"><div class="prompt input_prompt">
</div><div class="inner_cell">
<div class="text_cell_render border-box-sizing rendered_html">
<p>First, install the Humor Sans font.</p>
</div>
</div>
</div>
<div class="cell border-box-sizing code_cell rendered" id="cell-id=e575fd74">
<div class="input">
<div class="prompt input_prompt">In [1]:</div>
<div class="inner_cell">
<div class="input_area">
<div class="highlight hl-ipython3"><pre><span></span><span class="err">!</span><span class="n">wget</span> <span class="n">http</span><span class="p">:</span><span class="o">//</span><span class="n">antiyawn</span><span class="o">.</span><span class="n">com</span><span class="o">/</span><span class="n">uploads</span><span class="o">/</span><span class="n">Humor</span><span class="o">-</span><span class="n">Sans</span><span class="o">-</span><span class="mf">1.0</span><span class="o">.</span><span class="n">ttf</span> <span class="o">-</span><span class="n">O</span> <span class="o">~/.</span><span class="n">fonts</span><span class="o">/</span><span class="n">Humor</span>\ <span class="n">Sans</span><span class="o">.</span><span class="n">ttf</span>
</pre></div>
</div>
</div>
</div>
<div class="output_wrapper">
<div class="output">
<div class="output_area">
<div class="prompt"></div>
<div class="output_subarea output_stream output_stdout output_text">
<pre>--2014-07-14 02:00:41--  http://antiyawn.com/uploads/Humor-Sans-1.0.ttf
Resolving antiyawn.com (antiyawn.com)... 72.167.131.154
Connecting to antiyawn.com (antiyawn.com)|72.167.131.154|:80... </pre>
</div>
</div>
<div class="output_area">
<div class="prompt"></div>
<div class="output_subarea output_stream output_stdout output_text">
<pre>connected.
HTTP request sent, awaiting response... </pre>
</div>
</div>
<div class="output_area">
<div class="prompt"></div>
<div class="output_subarea output_stream output_stdout output_text">
<pre>200 OK
Length: 25832 (25K) [text/plain]
Saving to: ‘/root/.fonts/Humor Sans.ttf’

0% [ ] 0 --.-K/s </pre>

</div>
</div>
<div class="output_area">
<div class="prompt"></div>
<div class="output_subarea output_stream output_stdout output_text">
<pre>
100%[======================================&gt;] 25,832       136KB/s   in 0.2s

2014-07-14 02:00:41 (136 KB/s) - ‘/root/.fonts/Humor Sans.ttf’ saved [25832/25832]

</pre>
</div>
</div>
</div>
</div>
</div>
<div class="cell border-box-sizing text_cell rendered" id="cell-id=58dee1c6"><div class="prompt input_prompt">
</div><div class="inner_cell">
<div class="text_cell_render border-box-sizing rendered_html">
<p>Next, flush the matplotlib font cache.</p>
</div>
</div>
</div>
<div class="cell border-box-sizing code_cell rendered" id="cell-id=9d60939e">
<div class="input">
<div class="prompt input_prompt">In [2]:</div>
<div class="inner_cell">
<div class="input_area">
<div class="highlight hl-ipython3"><pre><span></span><span class="err">!</span><span class="n">rm</span> <span class="o">~/.</span><span class="n">cache</span><span class="o">/</span><span class="n">matplotlib</span><span class="o">/</span><span class="n">fontList</span><span class="o">.</span><span class="n">cache</span>
</pre></div>
</div>
</div>
</div>
</div>
<div class="cell border-box-sizing text_cell rendered" id="cell-id=ff81fd10"><div class="prompt input_prompt">
</div><div class="inner_cell">
<div class="text_cell_render border-box-sizing rendered_html">
<p>Then, enable inline plots in the style of <a href="http://xkcd.com/">xkcd</a>.</p>
</div>
</div>
</div>
<div class="cell border-box-sizing code_cell rendered" id="cell-id=48c7b1a9">
<div class="input">
<div class="prompt input_prompt">In [3]:</div>
<div class="inner_cell">
<div class="input_area">
<div class="highlight hl-ipython3"><pre><span></span><span class="o">%</span><span class="n">matplotlib</span> <span class="n">inline</span>
</pre></div>
</div>
</div>
</div>
</div>
<div class="cell border-box-sizing code_cell rendered" id="cell-id=28d936e8">
<div class="input">
<div class="prompt input_prompt">In [4]:</div>
<div class="inner_cell">
<div class="input_area">
<div class="highlight hl-ipython3"><pre><span></span><span class="kn">import</span> <span class="nn">matplotlib.pyplot</span> <span class="k">as</span> <span class="nn">plt</span>
<span class="n">plt</span><span class="o">.</span><span class="n">ioff</span><span class="p">()</span>
</pre></div>
</div>
</div>
</div>
</div>
<div class="cell border-box-sizing code_cell rendered" id="cell-id=2b3cbf75">
<div class="input">
<div class="prompt input_prompt">In [5]:</div>
<div class="inner_cell">
<div class="input_area">
<div class="highlight hl-ipython3"><pre><span></span><span class="n">plt</span><span class="o">.</span><span class="n">xkcd</span><span class="p">()</span>
</pre></div>
</div>
</div>
</div>
<div class="output_wrapper">
<div class="output">
<div class="output_area">
<div class="prompt output_prompt">Out[5]:</div>
<div class="output_text output_subarea output_execute_result">
<pre>&lt;matplotlib.rc_context at 0x7f39fe924d90&gt;</pre>
</div>
</div>
</div>
</div>
</div>
<div class="cell border-box-sizing text_cell rendered" id="cell-id=a7c52a71"><div class="prompt input_prompt">
</div><div class="inner_cell">
<div class="text_cell_render border-box-sizing rendered_html">
<p>Finally, humbly copy and tweak an <a href="http://matplotlib.org/xkcd/examples/showcase/xkcd.html">existing matplotlib example</a>.</p>
</div>
</div>
</div>
<div class="cell border-box-sizing code_cell rendered" id="cell-id=d1d7fbc4">
<div class="input">
<div class="prompt input_prompt">In [6]:</div>
<div class="inner_cell">
<div class="input_area">
<div class="highlight hl-ipython3"><pre><span></span><span class="n">fig</span> <span class="o">=</span> <span class="n">plt</span><span class="o">.</span><span class="n">figure</span><span class="p">(</span><span class="n">figsize</span><span class="o">=</span><span class="p">(</span><span class="mi">10</span><span class="p">,</span><span class="mi">5</span><span class="p">))</span>
<span class="n">ax</span> <span class="o">=</span> <span class="n">fig</span><span class="o">.</span><span class="n">add_subplot</span><span class="p">(</span><span class="mi">1</span><span class="p">,</span> <span class="mi">1</span><span class="p">,</span> <span class="mi">1</span><span class="p">)</span>
<span class="n">ax</span><span class="o">.</span><span class="n">bar</span><span class="p">([</span><span class="o">-</span><span class="mf">0.125</span><span class="p">,</span> <span class="mf">1.0</span><span class="o">-</span><span class="mf">0.125</span><span class="p">],</span> <span class="p">[</span><span class="mi">0</span><span class="p">,</span> <span class="mi">1</span><span class="p">],</span> <span class="mf">0.25</span><span class="p">)</span>
<span class="n">ax</span><span class="o">.</span><span class="n">spines</span><span class="p">[</span><span class="s1">'right'</span><span class="p">]</span><span class="o">.</span><span class="n">set_color</span><span class="p">(</span><span class="s1">'none'</span><span class="p">)</span>
<span class="n">ax</span><span class="o">.</span><span class="n">spines</span><span class="p">[</span><span class="s1">'top'</span><span class="p">]</span><span class="o">.</span><span class="n">set_color</span><span class="p">(</span><span class="s1">'none'</span><span class="p">)</span>
<span class="n">ax</span><span class="o">.</span><span class="n">xaxis</span><span class="o">.</span><span class="n">set_ticks_position</span><span class="p">(</span><span class="s1">'bottom'</span><span class="p">)</span>
<span class="n">ax</span><span class="o">.</span><span class="n">set_xticks</span><span class="p">([</span><span class="mi">0</span><span class="p">,</span> <span class="mi">1</span><span class="p">])</span>
<span class="n">ax</span><span class="o">.</span><span class="n">set_xlim</span><span class="p">([</span><span class="o">-</span><span class="mf">0.5</span><span class="p">,</span> <span class="mf">1.5</span><span class="p">])</span>
<span class="n">ax</span><span class="o">.</span><span class="n">set_ylim</span><span class="p">([</span><span class="mi">0</span><span class="p">,</span> <span class="mi">2</span><span class="p">])</span>
<span class="n">ax</span><span class="o">.</span><span class="n">set_xticklabels</span><span class="p">([</span><span class="s1">'Before IPython support'</span><span class="p">,</span> <span class="s1">'After IPython support'</span><span class="p">])</span>
<span class="n">plt</span><span class="o">.</span><span class="n">yticks</span><span class="p">([</span><span class="mi">0</span><span class="p">,</span> <span class="mi">1</span><span class="p">,</span> <span class="mi">2</span><span class="p">])</span>

<span class="n">plt</span><span class="o">.</span><span class="n">title</span><span class="p">(</span><span class="s2">"Useless plots on this blog"</span><span class="p">)</span>

</pre></div>
</div>
</div>
</div>
<div class="output_wrapper">
<div class="output">
<div class="output_area">
<div class="prompt output_prompt">Out[6]:</div>
<div class="output_text output_subarea output_execute_result">
<pre>&lt;matplotlib.text.Text at 0x7f39fe8340d0&gt;</pre>
</div>
</div>
</div>
</div>
</div>
<div class="cell border-box-sizing text_cell rendered" id="cell-id=2ef6edec"><div class="prompt input_prompt">
</div><div class="inner_cell">
<div class="text_cell_render border-box-sizing rendered_html">
<p><strong>And voilá!</strong></p>
</div>
</div>
</div>
<div class="cell border-box-sizing code_cell rendered" id="cell-id=2c470c19">
<div class="input">
<div class="prompt input_prompt">In [7]:</div>
<div class="inner_cell">
<div class="input_area">
<div class="highlight hl-ipython3"><pre><span></span><span class="n">plt</span><span class="o">.</span><span class="n">show</span><span class="p">()</span>
</pre></div>
</div>
</div>
</div>
<div class="output_wrapper">
<div class="output">
<div class="output_area">
<div class="prompt"></div>
<div class="output_png output_subarea">
<img alt="No description has been provided for this image" src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAkcAAAFECAYAAAAtP5rEAAAABHNCSVQICAgIfAhkiAAAAAlwSFlz
AAALEgAACxIB0t1+/AAAIABJREFUeJzs3XecFPX9P/DX9l6vAYfYUWligiAWIGKCX0XFCJZEscYS
JYkmakK+GjAqaoztaxf1GyuIvYT4kyIWFBULxtBUQNrVvd297e39++O+M95xheN2cG651/PxuAfc
7uxn3zs3O/Oaz3xmxiAiAiIiIiICABj1LoCIiIioN2E4IiIiImqF4YiIiIioFYYjIiIiolYYjoiI
iIhaYTgiIiLdbN++HQsWLEAsFtO7FCIVwxH1Gd999x2uuOIKOBwOHHrooUin0wCAfD6Pd955B2+9
9RZ++9vf4oILLlB/LrzwQvznP/8BADQ0NODUU0/FiSeeiGw22+V7ffTRR1i8eDH+/Oc/t2nvggsu
wLJly9pNH4lEMGfOHJSXl2PgwIFYs2ZNu2m++uorTJs2DVarFaeeeuouf34RQTQa7fC5NWvWYNy4
cbjiiiu63d53332HJUuW4P3334fWVwRZunQpxo0bB6vViuuvv75HbaxatQpLlizBV199tcuvXb16
NS666CI0NDT06L13t2+//RYXXXQR7HY7jjjiCBQKhV16/YYNG7BkyRIsWbIE7777brvXNzU14fTT
T8fPfvYzpFKpbrUZCoWwZMkSLF26VP1udSQcDmPGjBmYNm0a7HY7qqurcfrpp2PvvffG1q1bd+lz
EO02QrSHWLlypVxzzTWyatWqds+98847Ul5eLm63W26//XbJZDIiIrJp0yYZMmSIABAAYjAYZMiQ
ITJs2DAZNmyYjB8/XrZs2SIiIs8++6wAkH333Vfy+XyHNYTDYZkwYYLaHgAZPHiw2t6oUaPk888/
b/Oab775Rg499FAxmUxyySWXSDQabfN8oVCQefPmic1mk4qKCpk/f36n77+jefPmydVXXy0jR46U
iooKcTgc0r9/fznppJNk69at6nSzZs0SADJp0qRutXvrrbeK1WpVP2O/fv3klVdeaTNNXV2drFq1
qsuff//731IoFNTXpFIpufnmmwWA7L///vLhhx92q57W0um0nH766W3+pkOHDpV169a1mW7ZsmUy
a9Ysicfj7dq46KKLBIA8/PDDO32/RCKx08+5atUqicViUl9fL3feeWe3PsfDDz8sgwYNkg8++KDN
42+++aZ4vV7x+XzywAMPSDab7VZ7mzZtknQ6LQ888IB4vV4BICaTSQDIiBEj1OVcROSll14SADJg
wADJ5XI7bfuVV14Rn8+nznOfzye33XZbu+mWLFkiZWVlAkAOOeQQuemmm+Rvf/ubPP3003L//fd3
672IfggMR1Rympqa5IorrpBvv/22zeNvvfWWAJCpU6e2efyLL74Qk8kk48aNk6+++qrNc7fffrsA
kOHDh8sHH3wgX3/9dafvO336dAEgV199dafTvPrqqwJA+vfvL4sWLWr3fjtqaGiQQYMGyQEHHCBv
vvlmh9M8//zzAkBOO+00qa2t7bK9HSkbIgASCASksrJSPB6P+rsSxMaMGSMAZO7cuTtt89NPPxWD
wSAAZP78+fL888/LIYccIhaLpU1Auvzyy9uExM5+Nm3apL7muuuuE4PBIFdeeaWkUqld+qyKu+++
WwBIMBiUjz76SO655x7x+XxSXV3dJiBdd911AkBuuOGGdm2ceeaZAmCnfz+RlmDQnc/5yCOPyKef
firV1dWdtnXmmWeqn/v4448XAHL//ferzy9fvlwAyE9/+lP55ptvdmW2yPDhw+X3v/+9DBw4UCZP
nixvv/221NfXy0svvSTDhw+XAw88UA1IF198sQCQGTNm7LTdmpoaqaqqEgDy17/+Vd566y11B2HO
nDltpnM4HGIymeSRRx7pdqgj0gPDEZWclStXCgC59dZb2zxeKBTksMMOE7fbLfX19SIismbNGikv
L5fKykppbGxs19batWsFgDz//PM7fd/JkycLAPn73//e6TS5XE6MRmObjUJnotGoHHrooWI2m2XF
ihUdTrN48WKx2WwyYsSINj0s3RUMBsVsNsv8+fPV1ycSCXXj9Y9//ENERA488EABIG+88UaX7eXz
eRkxYoRUVFTIY489pj5eX18vhx56qFgsFrXnLhwOy8033yyXXnqpvPTSSzJw4EABIJMnT5ZzzjlH
zjnnnDa9Bffff78AkLPPPnuXP6di69atYrVaZfjw4fL++++rj3/88cfi8/lkr732knQ6LSLfhyMA
8vrrr7dpRwlHq1ev3ul75vN5efrpp2X69Ony7LPPqqHmxz/+sfo5Z86cKfX19bJy5couw5HVapXN
mzeLiMidd97ZJhx99tln4vV6ZeDAgR32du3M5MmT5bzzzmv3eDablWnTpqkBTkRk6tSpAkBuuumm
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
LPziF7/AkCFD0L9/f2zevBlVVVU4/PDDsX79euy///5qcN2RiODzzz/vdFzT3LlzUVtbi1GjRuH9
999HOBzGfffdh4kTJ3arNyEQCGDmzJn461//ildffRUOhwP19fXYZ599MG3aNCxatKjTXq/Wxo8f
j++++w4ej6fTELUzSiDubF50NmbN6/Wqr1OuSj1+/HjYbDYsW7YMixcvxjHHHIMPP/wQ6XQajz32
GDwezy711D377LNqgBcRfPfdd3A4HLjlllvUq6OffPLJmDVrFmbNmgURQaFQwF577aUG/g0bNiAS
ieD3v/89Fi5ciCOPPBKDBg3C1q1b4fF4cNBBB+HDDz/EyJEj1R6jHZ166qlYvXo1LrjgAtTX1+Ol
l17CKaec0uk8I/rBdefYWywWkylTpojRaBSDwSCXX375bjrKR9Q933zzjQwcOFCcTqf86Ec/EqPR
KDfffHObaV5++WUJBoPi9/tl8ODBcsUVV8i9997b5hoxtbW13T4rqlAoyGeffSYrVqyQ7du3dzhN
JBLp1sX51q1bJwMGDBC/3y9VVVVyySWXyOzZs9uc/n377beL3+8Xv98vo0aNkhkzZshTTz21S6dx
B4NBmTlz5k6ny2az8vHHH8uKFSukqamp0+kaGxtlzpw5cuONN8qKFSs6vDxCRwqFgowaNUpuv/32
Dp8/77zz1M/605/+VGbMmCFvvfVWt9pubf369XL11VfLww8/LF988UWX07Yec6Sla665Rk444YQO
x7FdddVVcu2113b4ukKhIC+99JLk83m58cYb24x7evLJJyUQCIjf75chQ4bIFVdcIQ899NAuXWqg
oaFBVqxYIQsWLJDf/OY38uabb8qKFStk48aNHU7/xRdfyIoVK7r8fiSTSXnwwQflmmuukffff1/C
4XC36yHqzQwiO78p0sknn4zPP/8cjz/+OO655x64XC4888wzP0B0I+rc1q1bcdddd2Hr1q345S9/
iRNPPFHvknqdI444ApdddhnOPfdcvUvpdY477jiMGDECd9xxxw/2nm+99RYOOOAA7Lvvvl1Ot3Dh
QsyfPx9z5sxB//79f6DqiEjRrXB09913Y+zYsRg9ejSOOeYYHHnkkbj11lt/iPqIqAgiwkMVnVBO
Z9dqjBQR7Tm6dbbab3/7W4wePRpz587F5s2b8Yc//KHN8yKCv/zlLzAYDJ3+zJo1a3fUT0RdYDDq
nN/vZzAi2oPNmjWrx7mk26fyZ7NZ3HHHHbj44ovbnUWzfPly3HDDDVi4cCEv4kVEREQlrdvhaObM
mbDb7eoZDa1ls1kALafTduMoHREREVGv1a0xR//5z38wbtw4HH/88Zg5cyYA4IADDlBPc37ttddw
8skn4+OPP25zcTkiIiKiUtOtnqNHH30UjY2NePrppzF06FAMHTq0zYDscDgMoOUYPhEREVEp69ZF
IK+++mqMHj0aY8eOhd/vx+LFi3HkkUeqzys3+1QuYkZERERUqroVjvr164czzjhD/f3UU09t83wo
FAIABINBDUsjIiIi+uFpcuPZUCgEr9fb6aXiiYiIiEqFJuEoHA5zvBERERHtETQJR/F4HC6XS4um
iIiIiHSlSThKJBKd3mmaiIiIqJRoEo4ikQjPVCMiIqI9gibhqKamBv369dOiKSIiIiJdaXa2Gm/g
SERERHsCzQZkO51OLZoiIiIi0lXR4SiTySCTycDtdmtRDxEREZGuig5Hzc3NAHjrECIiItozFB2O
otEoAIYjIiIi2jMUHY4aGxsBAGVlZUUXQ0RERKS3osNRXV0dAKCioqLoYoiIiIj0VnQ4CofDAIBA
IFB0MURERER602xAtsfjKboYIiIiIr0xHBERERG1UnQ4isViAACXy1V0MURERER606TnyOl0wmQy
aVEPERERka6KDkfxeJy9RkRERLTHKDocpVIp2O12LWohIiIi0l3R4SibzcJisWhRCxEREZHuig5H
6XQaNptNi1qIiIiIdMdwRERERNRK0eEok8nAarVqUQsRERGR7ooOR7lcDmazWYtaiIiIiHRXdDgq
FAowGotuhoiIiKhXKDrViAgMBoMWtRARERHpTpMuH/YcERER0Z5Ck1QjIlo0Q0RERKQ7hiMiIiKi
VooOR0ajEYVCQYtaiIiIiHRXdDgymUzI5/Na1EJERESku6LDkcViQTab1aIWIiIiIt0xHBERERG1
UnQ4stlsSKfTWtRCREREpLuiw5HD4UAymdSiFiIiIiLdFR2O7HY7UqmUFrUQERER6a7ocGS1WpHJ
ZLSohYiIiEh3HHNERERE1ErR4cjj8SCZTCKXy2lRDxEREZGuig5HXq8XABCLxYouhoiIiEhvRYcj
p9MJAEgkEkUXQ0RERKS3osNRIBAAADQ2NhZdDBEREZHeig5HFRUVAICGhoaiiyEiIiLSW9HhyOfz
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
Kna7XW666SYpFAo7rfuhhx6SSCQis2fPFrPZLACkf//+UlVVJSaTSX77299KPp+XVColZWVlcuut
t9UEtH4AABcNSURBVLZpo6amRjKZjJxxxhldfqa1a9fKJZdcIq+//nq7Ot577z1pbm5Wf9+0aZM4
HA7Za6+95Ne//rX4/X45+uij1Wny+bwAkNtuu61NO6+//roAkH/+8587/ZsVCgWZOnWqlJeXy7x5
87qcVzNmzJCjjz5a/f2iiy7qcD1y4YUXisj3f7fWP3a7Xe6888527w9ALrjgAjn88MPF4XDIkiVL
1Gnuv/9+ASBer1cOOuigNn/rzz77TERE7rrrri7n+z/+8Y+dzos9EcPRDkaMGCEHHXSQfPrpp7Ju
3TpZt26dPPTQQ2IymWTLli0yf/588Xg8kk6nO22jurpapk2b1unzf/zjH8Xr9aphIRaLybhx42Sv
vfaSpqYm2bp1qwCQP/7xj2o4SaVS8uSTT8qQIUNk2LBhks1mZcmSJQJAotHoLn/OUCgkAOSuu+6S
U045RSZPnixr166VZDIp2WxW3n77bamoqJDJkydLNpuV//3f/xW/3y+RSERERJLJpAwaNEiWLVsm
ixYtkuOPP16uvvpqOeSQQwSAHHXUUTJhwgSZNm2abNy4Ua6//np56KGH2tVxww03qMFTROTss8+W
yspKefnll0VEpK6uToYNGybDhw+XbDYrIqIGxeeff159nRKOlNd1Zc6cOWIymeSjjz5q99xxxx3X
JqR89dVXYrFY5KmnnhIRkUsvvVQMBoPccsstsnbtWlm7dq0aZBcuXCg//vGPxe/3yzPPPCPr1q2T
r776So4++mgxGo1qqH333XfFYDDIBRdcIJlMRkRaQrfJZJLFixeLiMhhhx0mRx11VJuQu3TpUjnt
tNPE4XDIF198IRs2bJBzzjlHpk+fLj//+c8FgBx88MEyYcIEmThxorz55ps7nRfUO9x3333i9Xrl
iCOOkOrqagmHwyIiMnr0aDnyyCPbbXgzmYxcf/31cvzxx8uf/vQnMRgMUl5eLhMmTJAJEybIDTfc
ICIiZ511lpxxxhmdvu/1118vgUBAli9frj62YcMGue6668RgMLTZGHfkq6++EgAyf/58GT16tJx/
/vmybt06yWQykkql5LXXXhO32y3nn3++FAoFmTNnjuy9997qdzkUConP55M1a9bIiy++KMcdd5zM
nDlTBg4cKCaTSY455hiZMGGCnHPOOVJfXy+/+tWv5NVXX21Xx2WXXSYvvfSS+vvEiRPV9ZPymfbe
e2+ZOHGiFAoFNRyZzeb/396ZB0V1bH/8OyMgmw6LIA5EQcWtgEhQIFGeQIkZGAW3URQsCxdEKZco
bqloRMUl0UrERBN3g6wKLgiioiwuAUWjpaKOqOCCCyAwgAtk5vz+oKZ/XGcY8SXvxZfcz3/06b63
+w739Olzu89hdYj+3zgqLCzUOW4iojlz5pChoSFb1Kp59eoVeXp6skUMEVFubi4JBAL2fgcFBZGB
gQFt3bqVbt++Tbdu3aJRo0YRALpy5QqJxWKytbWlQ4cOkVwupytXrpCTkxMZGRmxZ6deQEVFRbEx
RUREkJGREV25coWImheSgYGB9OLFCyJqNgozMjJo2LBhZGFhQWVlZXT9+nWSyWQUHh5OQ4cOJQD0
8ccfk7e3N0kkEiooKHjns/g7whtHbxEZGUmff/45p+zQoUPMe5CZmUlCoZA2b95M8fHxFB8fT0eP
HuUoL7FYTL6+vlRTU0MKhYLjmaioqKCOHTvS4cOHOfeor68nR0dH+uGHH+jNmzdka2tLqampTP7y
5UtSKBS0aNEiAkAnTpygixcvEgBav34960taWppOT4gahUJBAOi7776joKAgpjRaEhsbS8bGxlRV
VUV1dXVkaWnJlO6qVavI2tqaeVTUrFixgnx9fTXuJ5VKaffu3RrlK1eupB9//JGIiG7fvk2GhoYa
iun58+dkYWHBDB8rKysCQD179qT6+noiIioqKiIA9ODBA53jfv36NZmampKrqyuVl5dzZOXl5QSA
VqxYwSmPjIyk7t2709OnTykiIoL69+/PkWdmZhIAOn/+PLm5udH06dM58ujoaDIxMaHq6mpSqVTk
5+dH4eHhGn0LDw8niURCRERTpkyhsLAwJmtsbCSFQsEM4jlz5nDaqv8XXr16pXP8PB8eTU1NZG9v
T5s2baKamhoyMzNjxvjAgQPJycmJqqqqSKFQaLxvamxtbSkxMVGjPDw8nHr16kVxcXFMR6gnTiKi
gwcPklgsZoswlUpFCoWCampqyMrKihwcHHT2XS6XEwBKSkoid3d3Cg0N1aizdOlSsrKyoqamJnr4
8CEZGxuzheGsWbPI2dlZo82MGTMoJCREo/yTTz6hrKwsjfKZM2dSWloaETV7kYyNjamkpIRT5+7d
u6Svr0+FhYX0+++/M4+Mh4cHW6Skp6eTsbExM05bo6KiggCQr68v+2Kg5vLlywRAYzE4evRocnV1
pdraWgoKCiJ/f3+OfOfOnSQUCqmkpITEYjEtX76cI4+IiGA6V6lUkouLC3399decOkqlkgIDA5nu
8Pf3py+//JLJX79+TQqFghISEggArV27ltP+yJEjZGFh0aY55O8Obxy9RXJyMtnb29OBAwdow4YN
tGzZMurSpQtlZ2czOQBycHBgrs7g4GCmtO7fv08CgYDjDl2yZAm7/pIlS2j06NFa771ixQry8vIi
ouYJ2cfHh/Ly8mjIkCHMXS0UCkkmk1FjYyObKLt160ZCoZD09fVp+PDhbZogGxoamJt23rx5BICK
ioqY/NmzZxqfr/bu3UsODg4UHx9PNjY2FBcXp3Hd6OhojZeeqNkT8vDhQ43yqKgo5mYPDQ3VmPTV
TJs2jSZMmEByuZwEAgH99NNPZGdnx+rHxsYSgDa91JmZmTR8+HAyMjKibdu2MaMwOTmZ9PT0OJ8v
iIjy8/MJAC1dupQiIiJoyJAhTFZZWUnOzs4kk8lIpVKRm5sbRUVFMfm1a9fIwsKCue/Pnj1LFhYW
Wr19agOvurqajh07RkKhkO7du0cjR45k3jIA5OrqSjdu3NDa9l2fQXg+PAoKCkgkEjGv7IIFC8jP
z4/q6urI0NCQo0smTZqk9Rp2dnbMOGjJhAkTyMjIiGxsbAgAderUiTNpNzQ0UMeOHSkxMZEWL17M
PL/qugkJCTr7/vDhQxIIBJSUlETjx48nAJz3vKSkhExNTTmfr9atW0f9+/enuLg4MjExYbq1JRER
ETRlyhSNchsbG60GYkhICP3yyy9E1Ow1envSVyOVSmn+/PmUn59P7du3p+3bt5O5uTmrv3TpUrK2
ttY5ZjVJSUnk4+ND5ubmlJKSwsq///57EolEVF1dzamvnjtiY2MpKCiIgoODmaysrIy6devG9JlY
LKaNGzcy+ZkzZ8jIyIjp3P3791P37t21Pov09HQSiUTU2NhIu3btIktLS5LL5SSRSEgkErHf18vL
S0Mnp6enU+fOnds0/r87/I6st/D29kZpaSlWr16N+/fvo7a2Fl9++SXbKJebmwsvLy/k5+ejrKwM
xsbGsLKyYu1tbW3x2Wef4dy5cwgLC0O/fv0gkUiY/MCBA9i/f7/We7948QJmZmYAAJlMBm9vb+Tn
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
YII=
"/>
</div>
</div>
</div>
</div>
</div>
<div class="cell border-box-sizing text_cell rendered" id="cell-id=74942d00"><div class="prompt input_prompt">
</div><div class="inner_cell">
<div class="text_cell_render border-box-sizing rendered_html">
<p>The future is bright, I tell you.</p>
</div>
</div>
</div>
<div class="cell border-box-sizing text_cell rendered" id="cell-id=e89db455"><div class="prompt input_prompt">
</div><div class="inner_cell">
<div class="text_cell_render border-box-sizing rendered_html">
<h2 id="Genericize-It">Genericize It<a class="anchor-link" href="#Genericize-It">¶</a></h2>
</div>
</div>
</div>
<div class="cell border-box-sizing text_cell rendered" id="cell-id=feaa65d5"><div class="prompt input_prompt">
</div><div class="inner_cell">
<div class="text_cell_render border-box-sizing rendered_html">
<p>So I've scratched my two blog itches, and, as expected from itching, have created more. The fact that my blog generator is now in a portable, reusable container yet still somewhat hardcoded to this site bugs me. With a bit more elbow grease, I believe I can make a Docker image that can seed a blog like mine for any purpose simply by setting a few environment variables.</p>
<p>When or whether I get around to scratching this itch is an open question. Meanwhile, I solemnly promise never to write another veribified heading on this blog (but I refuse to make a similar promise for xkcd-style plots).</p>
</div>
</div>
</div>
