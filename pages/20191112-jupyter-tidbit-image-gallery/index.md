---
title: Jupyter Tidbit: Show an image gallery
date: 2019-11-12
excerpt: JupyterLab and Jupyter Notebook can display HTML-embedded images in notebook documents. You can use the IPython.display.HTML class to structure these images into a basic image gallery.
author_comment: This post originates from a <a href="https://gist.github.com/parente/691d150c934b89ce744b5d54103d7f1e">gist</a> that supports comments, forks, and execution in <a href="https://mybinder.org/v2/gist/parente/691d150c934b89ce744b5d54103d7f1e/master">binder</a>.
template: notebook.mako
---

### Summary

JupyterLab and Jupyter Notebook can display HTML-embedded images in notebook documents. You can use
the `IPython.display.HTML` class to structure these images into a basic image gallery.

### Example

[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gist/parente/691d150c934b89ce744b5d54103d7f1e/master?filepath=gallery.ipynb)

The notebook below defines a `gallery()` function that accepts a list of image URLs, local image
file paths, or bytes in memory. The function displays the images from left-to-right, top-to-bottom
in the notebook. An optional `max_height` parameter scales all images to the same height to create
more regular looking rows.

The notebook includes two demos of the function output.

### Why is this useful?

You may find a gallery view useful when you need to visually scan a large set of images. The
horizontal layout helps reduce notebook scrolling. The fixed height option lets you pack more images
on the screen at once and spot coarse differences.

<div class="cell border-box-sizing text_cell rendered"><div class="prompt input_prompt">

</div><div class="inner_cell">
<div class="text_cell_render border-box-sizing rendered_html">
<h4 class="embedFilename"><i class="fa fa-file" aria-hidden="true"></i> gallery.ipynb</h4>
</div>
</div>
</div>
<div class="cell border-box-sizing text_cell rendered"><div class="prompt input_prompt">
</div><div class="inner_cell">
<div class="text_cell_render border-box-sizing rendered_html">
<h2 id="Gallery">Gallery<a class="anchor-link" href="#Gallery">&#182;</a></h2>
</div>
</div>
</div>
<div class="cell border-box-sizing code_cell rendered">
<div class="input">
<div class="prompt input_prompt">In&nbsp;[1]:</div>
<div class="inner_cell">
    <div class="input_area">
<div class=" highlight hl-ipython3">
<pre><span></span><span class="kn">from</span> <span class="nn">IPython.display</span> <span class="k">import</span> <span class="n">HTML</span><span class="p">,</span> <span class="n">Image</span>

<span class="k">def</span> <span class="nf">_src_from_data</span><span class="p">(</span><span class="n">data</span><span class="p">):</span>
    <span class="sd">&quot;&quot;&quot;Base64 encodes image bytes for inclusion in an HTML img element&quot;&quot;&quot;</span>
    <span class="n">img_obj</span> <span class="o">=</span> <span class="n">Image</span><span class="p">(</span><span class="n">data</span><span class="o">=</span><span class="n">data</span><span class="p">)</span>
    <span class="k">for</span> <span class="n">bundle</span> <span class="ow">in</span> <span class="n">img_obj</span><span class="o">.</span><span class="n">\_repr_mimebundle_</span><span class="p">():</span>
        <span class="k">for</span> <span class="n">mimetype</span><span class="p">,</span> <span class="n">b64value</span> <span class="ow">in</span> <span class="n">bundle</span><span class="o">.</span><span class="n">items</span><span class="p">():</span>
            <span class="k">if</span> <span class="n">mimetype</span><span class="o">.</span><span class="n">startswith</span><span class="p">(</span><span class="s1">&#39;image/&#39;</span><span class="p">):</span>
                <span class="k">return</span> <span class="n">f</span><span class="s1">&#39;data:</span><span class="si">{mimetype}</span><span class="s1">;base64,</span><span class="si">{b64value}</span><span class="s1">&#39;</span>

<span class="k">def</span> <span class="nf">gallery</span><span class="p">(</span><span class="n">images</span><span class="p">,</span> <span class="n">row_height</span><span class="o">=</span><span class="s1">&#39;auto&#39;</span><span class="p">):</span>
    <span class="sd">&quot;&quot;&quot;Shows a set of images in a gallery that flexes with the width of the notebook.</span>
    <span class="sd"> </span>
    <span class="sd"> Parameters</span>
    <span class="sd"> ----------</span>
    <span class="sd"> images: list of str or bytes</span>
        <span class="sd"> URLs or bytes of images to display</span>
    <span class="sd"> row_height: str</span>
        <span class="sd"> CSS height value to assign to all images. Set to &#39;auto&#39; by default to show images</span>
        <span class="sd"> with their native dimensions. Set to a value like &#39;250px&#39; to make all rows</span>
        <span class="sd"> in the gallery equal height.</span>
    <span class="sd"> &quot;&quot;&quot;</span>
    <span class="n">figures</span> <span class="o">=</span> <span class="p">[]</span>
    <span class="k">for</span> <span class="n">image</span> <span class="ow">in</span> <span class="n">images</span><span class="p">:</span>
        <span class="k">if</span> <span class="nb">isinstance</span><span class="p">(</span><span class="n">image</span><span class="p">,</span> <span class="nb">bytes</span><span class="p">):</span>
            <span class="n">src</span> <span class="o">=</span> <span class="n">\_src_from_data</span><span class="p">(</span><span class="n">image</span><span class="p">)</span>
            <span class="n">caption</span> <span class="o">=</span> <span class="s1">&#39;&#39;</span>
        <span class="k">else</span><span class="p">:</span>
            <span class="n">src</span> <span class="o">=</span> <span class="n">image</span>
            <span class="n">caption</span> <span class="o">=</span> <span class="n">f</span><span class="s1">&#39;&lt;figcaption style=&quot;font-size: 0.6em&quot;&gt;</span><span class="si">{image}</span><span class="s1">&lt;/figcaption&gt;&#39;</span>
        <span class="n">figures</span><span class="o">.</span><span class="n">append</span><span class="p">(</span><span class="n">f</span><span class="s1">&#39;&#39;&#39;</span>
<span class="s1"> &lt;figure style=&quot;margin: 5px !important;&quot;&gt;</span>
<span class="s1"> &lt;img src=&quot;</span><span class="si">{src}</span><span class="s1">&quot; style=&quot;height: </span><span class="si">{row_height}</span><span class="s1">&quot;&gt;</span>
<span class="s1"> </span><span class="si">{caption}</span><span class="s1"></span>
<span class="s1"> &lt;/figure&gt;</span>
<span class="s1"> &#39;&#39;&#39;</span><span class="p">)</span>
    <span class="k">return</span> <span class="n">HTML</span><span class="p">(</span><span class="n">data</span><span class="o">=</span><span class="n">f</span><span class="s1">&#39;&#39;&#39;</span>
<span class="s1"> &lt;div style=&quot;display: flex; flex-flow: row wrap; text-align: center;&quot;&gt;</span>
<span class="s1"> {&#39;&#39;.join(figures)}</span>
<span class="s1"> &lt;/div&gt;</span>
<span class="s1"> &#39;&#39;&#39;</span><span class="p">)</span>

</pre></div>

    </div>

</div>
</div>

</div>
<div class="cell border-box-sizing text_cell rendered"><div class="prompt input_prompt">
</div><div class="inner_cell">
<div class="text_cell_render border-box-sizing rendered_html">
<h2 id="Demos">Demos<a class="anchor-link" href="#Demos">&#182;</a></h2>
</div>
</div>
</div>
<div class="cell border-box-sizing text_cell rendered"><div class="prompt input_prompt">
</div><div class="inner_cell">
<div class="text_cell_render border-box-sizing rendered_html">
<p>Generate URLs for images of varying sizes using <a href="https://picsum.photos/">Lorem Picsum</a>.</p>

</div>
</div>
</div>
<div class="cell border-box-sizing code_cell rendered">
<div class="input">
<div class="prompt input_prompt">In&nbsp;[2]:</div>
<div class="inner_cell">
    <div class="input_area">
<div class=" highlight hl-ipython3"><pre><span></span><span class="kn">import</span> <span class="nn">random</span>

<span class="n">urls</span> <span class="o">=</span> <span class="p">[]</span>
<span class="k">for</span> <span class="n">i</span> <span class="ow">in</span> <span class="nb">range</span><span class="p">(</span><span class="mi">25</span><span class="p">):</span>
    <span class="n">width</span> <span class="o">=</span> <span class="n">random</span><span class="o">.</span><span class="n">randrange</span><span class="p">(</span><span class="mi">400</span><span class="p">,</span> <span class="mi">800</span><span class="p">)</span>
    <span class="n">height</span> <span class="o">=</span> <span class="n">random</span><span class="o">.</span><span class="n">randrange</span><span class="p">(</span><span class="mi">400</span><span class="p">,</span> <span class="mi">800</span><span class="p">)</span>
    <span class="n">urls</span><span class="o">.</span><span class="n">append</span><span class="p">(</span><span class="n">f</span><span class="s1">&#39;https://picsum.photos/</span><span class="si">{width}</span><span class="s1">/</span><span class="si">{height}</span><span class="s1">?random=</span><span class="si">{i}</span><span class="s1">&#39;</span><span class="p">)</span>

</pre></div>

    </div>

</div>
</div>

</div>
<div class="cell border-box-sizing text_cell rendered"><div class="prompt input_prompt">
</div><div class="inner_cell">
<div class="text_cell_render border-box-sizing rendered_html">
<p>Render a gallery of the images with a row height.</p>

</div>
</div>
</div>
<div class="cell border-box-sizing code_cell rendered">
<div class="input">
<div class="prompt input_prompt">In&nbsp;[4]:</div>
<div class="inner_cell">
    <div class="input_area">
<div class=" highlight hl-ipython3"><pre><span></span><span class="n">gallery</span><span class="p">(</span><span class="n">urls</span><span class="p">,</span> <span class="n">row_height</span><span class="o">=</span><span class="s1">&#39;150px&#39;</span><span class="p">)</span>
</pre></div>

    </div>

</div>
</div>

<div class="output_wrapper">
<div class="output">

<div class="output_area">

    <div class="prompt output_prompt">Out[4]:</div>

<div class="output_html rendered_html output_subarea output_execute_result">

        <div style="display: flex; flex-flow: row wrap; text-align: center;">

            <figure style="margin: 5px !important;">
              <img src="https://picsum.photos/514/613?random=0" style="height: 150px">
              <figcaption style="font-size: 0.6em">https://picsum.photos/514/613?random=0</figcaption>
            </figure>

            <figure style="margin: 5px !important;">
              <img src="https://picsum.photos/777/400?random=1" style="height: 150px">
              <figcaption style="font-size: 0.6em">https://picsum.photos/777/400?random=1</figcaption>
            </figure>

            <figure style="margin: 5px !important;">
              <img src="https://picsum.photos/516/555?random=2" style="height: 150px">
              <figcaption style="font-size: 0.6em">https://picsum.photos/516/555?random=2</figcaption>
            </figure>

            <figure style="margin: 5px !important;">
              <img src="https://picsum.photos/433/786?random=3" style="height: 150px">
              <figcaption style="font-size: 0.6em">https://picsum.photos/433/786?random=3</figcaption>
            </figure>

            <figure style="margin: 5px !important;">
              <img src="https://picsum.photos/503/508?random=4" style="height: 150px">
              <figcaption style="font-size: 0.6em">https://picsum.photos/503/508?random=4</figcaption>
            </figure>

            <figure style="margin: 5px !important;">
              <img src="https://picsum.photos/690/574?random=5" style="height: 150px">
              <figcaption style="font-size: 0.6em">https://picsum.photos/690/574?random=5</figcaption>
            </figure>

            <figure style="margin: 5px !important;">
              <img src="https://picsum.photos/513/448?random=6" style="height: 150px">
              <figcaption style="font-size: 0.6em">https://picsum.photos/513/448?random=6</figcaption>
            </figure>

            <figure style="margin: 5px !important;">
              <img src="https://picsum.photos/764/580?random=7" style="height: 150px">
              <figcaption style="font-size: 0.6em">https://picsum.photos/764/580?random=7</figcaption>
            </figure>

            <figure style="margin: 5px !important;">
              <img src="https://picsum.photos/408/767?random=8" style="height: 150px">
              <figcaption style="font-size: 0.6em">https://picsum.photos/408/767?random=8</figcaption>
            </figure>

            <figure style="margin: 5px !important;">
              <img src="https://picsum.photos/429/690?random=9" style="height: 150px">
              <figcaption style="font-size: 0.6em">https://picsum.photos/429/690?random=9</figcaption>
            </figure>

            <figure style="margin: 5px !important;">
              <img src="https://picsum.photos/511/738?random=10" style="height: 150px">
              <figcaption style="font-size: 0.6em">https://picsum.photos/511/738?random=10</figcaption>
            </figure>

            <figure style="margin: 5px !important;">
              <img src="https://picsum.photos/594/528?random=11" style="height: 150px">
              <figcaption style="font-size: 0.6em">https://picsum.photos/594/528?random=11</figcaption>
            </figure>

            <figure style="margin: 5px !important;">
              <img src="https://picsum.photos/523/574?random=12" style="height: 150px">
              <figcaption style="font-size: 0.6em">https://picsum.photos/523/574?random=12</figcaption>
            </figure>

            <figure style="margin: 5px !important;">
              <img src="https://picsum.photos/702/625?random=13" style="height: 150px">
              <figcaption style="font-size: 0.6em">https://picsum.photos/702/625?random=13</figcaption>
            </figure>

            <figure style="margin: 5px !important;">
              <img src="https://picsum.photos/563/709?random=14" style="height: 150px">
              <figcaption style="font-size: 0.6em">https://picsum.photos/563/709?random=14</figcaption>
            </figure>

            <figure style="margin: 5px !important;">
              <img src="https://picsum.photos/468/441?random=15" style="height: 150px">
              <figcaption style="font-size: 0.6em">https://picsum.photos/468/441?random=15</figcaption>
            </figure>

            <figure style="margin: 5px !important;">
              <img src="https://picsum.photos/552/680?random=16" style="height: 150px">
              <figcaption style="font-size: 0.6em">https://picsum.photos/552/680?random=16</figcaption>
            </figure>

            <figure style="margin: 5px !important;">
              <img src="https://picsum.photos/619/421?random=17" style="height: 150px">
              <figcaption style="font-size: 0.6em">https://picsum.photos/619/421?random=17</figcaption>
            </figure>

            <figure style="margin: 5px !important;">
              <img src="https://picsum.photos/625/578?random=18" style="height: 150px">
              <figcaption style="font-size: 0.6em">https://picsum.photos/625/578?random=18</figcaption>
            </figure>

            <figure style="margin: 5px !important;">
              <img src="https://picsum.photos/536/596?random=19" style="height: 150px">
              <figcaption style="font-size: 0.6em">https://picsum.photos/536/596?random=19</figcaption>
            </figure>

            <figure style="margin: 5px !important;">
              <img src="https://picsum.photos/526/735?random=20" style="height: 150px">
              <figcaption style="font-size: 0.6em">https://picsum.photos/526/735?random=20</figcaption>
            </figure>

            <figure style="margin: 5px !important;">
              <img src="https://picsum.photos/752/408?random=21" style="height: 150px">
              <figcaption style="font-size: 0.6em">https://picsum.photos/752/408?random=21</figcaption>
            </figure>

            <figure style="margin: 5px !important;">
              <img src="https://picsum.photos/775/516?random=22" style="height: 150px">
              <figcaption style="font-size: 0.6em">https://picsum.photos/775/516?random=22</figcaption>
            </figure>

            <figure style="margin: 5px !important;">
              <img src="https://picsum.photos/424/423?random=23" style="height: 150px">
              <figcaption style="font-size: 0.6em">https://picsum.photos/424/423?random=23</figcaption>
            </figure>

            <figure style="margin: 5px !important;">
              <img src="https://picsum.photos/687/400?random=24" style="height: 150px">
              <figcaption style="font-size: 0.6em">https://picsum.photos/687/400?random=24</figcaption>
            </figure>

        </div>

</div>

</div>

</div>
</div>

</div>
<div class="cell border-box-sizing text_cell rendered"><div class="prompt input_prompt">
</div><div class="inner_cell">
<div class="text_cell_render border-box-sizing rendered_html">
<p>Generate in-memory PNGs for avatar characters using the <a href="https://github.com/daboth/pagan">pagan</a> library.</p>

</div>
</div>
</div>
<div class="cell border-box-sizing code_cell rendered">
<div class="input">
<div class="prompt input_prompt">In&nbsp;[5]:</div>
<div class="inner_cell">
    <div class="input_area">
<div class=" highlight hl-ipython3"><pre><span></span><span class="kn">import</span> <span class="nn">io</span>
<span class="kn">import</span> <span class="nn">pagan</span>

<span class="n">pngs</span> <span class="o">=</span> <span class="p">[]</span>
<span class="k">for</span> <span class="n">i</span> <span class="ow">in</span> <span class="nb">range</span><span class="p">(</span><span class="mi">50</span><span class="p">):</span>
    <span class="n">buffer</span> <span class="o">=</span> <span class="n">io</span><span class="o">.</span><span class="n">BytesIO</span><span class="p">()</span>
    <span class="n">pagan</span><span class="o">.</span><span class="n">Avatar</span><span class="p">(</span><span class="n">f</span><span class="s1">&#39;</span><span class="si">{i}</span><span class="s1">&#39;</span><span class="p">)</span><span class="o">.</span><span class="n">img</span><span class="o">.</span><span class="n">save</span><span class="p">(</span><span class="n">buffer</span><span class="p">,</span> <span class="s1">&#39;png&#39;</span><span class="p">)</span>
    <span class="n">pngs</span><span class="o">.</span><span class="n">append</span><span class="p">(</span><span class="n">buffer</span><span class="o">.</span><span class="n">getvalue</span><span class="p">())</span>

</pre></div>

    </div>

</div>
</div>

</div>
<div class="cell border-box-sizing text_cell rendered"><div class="prompt input_prompt">
</div><div class="inner_cell">
<div class="text_cell_render border-box-sizing rendered_html">
<p>Render a gallery of the avatars with their natural dimensions.</p>

</div>
</div>
</div>
<div class="cell border-box-sizing code_cell rendered">
<div class="input">
<div class="prompt input_prompt">In&nbsp;[6]:</div>
<div class="inner_cell">
    <div class="input_area">
<div class=" highlight hl-ipython3"><pre><span></span><span class="n">gallery</span><span class="p">(</span><span class="n">pngs</span><span class="p">)</span>
</pre></div>

    </div>

</div>
</div>

<div class="output_wrapper">
<div class="output">

<div class="output_area">

    <div class="prompt output_prompt">Out[6]:</div>

<div class="output_html rendered_html output_subarea output_execute_result">

        <div style="display: flex; flex-flow: row wrap; text-align: center;">

            <figure style="margin: 5px !important;">
              <img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAIAAAACACAYAAADDPmHLAAACTElEQVR4nO3cIU4DQRSA4UJI0JU4MJhVmx6FMxTDATBIgkBhQLBnaqpqMMXhqIIEA9xgX+BlMrP9/89vmG7+TPJmd5nNJEmSJEkSxUHtBZS2Xp3+ZK7vF697fY8Oay9AdRkAnAHAGQCcAcAZAJwBwE1+xs3O+VlTPydwB4AzADgDgDMAOAOAMwA4A4A7qr0AuuXucvQcY5g/j54zZK93B4AzADgDgDMAOAOAMwA4A4Cb/DlA9Dx+6t8FRHN+ljsAnAHAGQCcAcAZAJwBwBkAXDjjvm2/qr53/373WfPPF/dwf526PnreH3EHgDMAOAOAMwA4A4AzADgDgAvfBzg5Ox6dM6Nzguj66Hl9P4w/j98sd1XPKbphnvp9w3z89/k+gIoyADgDgDMAOAOAMwA4A4Ar/l1AOOcH793XnvMj0fq6Re6c4Ok/i/oDdwA4A4AzADgDgDMAOAOAMwC44ucAtb+vb110f5a7me8DqBwDgDMAOAOAMwA4A4AzALjm/09g9N595PZxk5qjb666vT7HcAeAMwA4A4AzADgDgDMAOAOAS58DRN//lxZ/d5Cb47PfNbTOHQDOAOAMAM4A4AwAzgDgDACu+Rm29Tm89fVF3AHgDADOAOAMAM4A4AwAzgDgqs+oU5+jI63/PncAOAOAMwA4A4AzADgDgDMAuOL/H+BlvRqdgz++L0ovoWnR/TnvF0XPCdwB4AwAzgDgDADOAOAMAM4A4NIzZjTHZpWeg0tr/f64A8AZAJwBwBkAnAHAGQCcAUiSJEmSJEH8Aj3rdqJfotTZAAAAAElFTkSuQmCC

" style="height: auto">

            </figure>

            <figure style="margin: 5px !important;">
              <img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAIAAAACACAYAAADDPmHLAAACTklEQVR4nO3dLU4DURRA4UKwrKJbIBPECIKpxeIwsAhERRVroAaJxNagRpCmvqqrICSkBnbwbsLN5L3hnM/S38nJS+6bzjCbSZIkSZIkipPaH2Bsw/b6J/P8vnv/18fotPYHUF0GAGcAcAYAZwBwBgBnAHCTn3Gzc37W1PcJXAHgDADOAOAMAM4A4AwAzgDgzqIH7G6ei3P2xdvDpOfg1s1X58Xjf1h+po6/KwCcAcAZAJwBwBkAnAHAGQBcuA8QifYJItl9hOh8vNcFlLkCwBkAnAHAGQCcAcAZAJwBwIX7ANGcnt0HiGzmq9Trf91m3/8q9f6Lw7LpfQRXADgDgDMAOAOAMwA4A4AzALj07wEi0T5CdL6+78pzdHafICua8+PvV/f3Bq4AcAYAZwBwBgBnAHAGAGcAcOkZNPo9wPfja/H50Rxce87PivYJouv/s6L7B7gCwBkAnAHAGQCcAcAZAJwBwI3+e4Da57tbF83p3idQozIAOAOAMwA4A4AzADgDgBt9HyAre3395csmdb79425RdR8jO+dHXAHgDADOAOAMAM4A4AwAzgDgJn+ufuzr71u/vj/LFQDOAOAMAM4A4AwAzgDgDACu+Rm29Tm89c8XcQWAMwA4A4AzADgDgDMAOAOAqz6jTn2OjrT+/VwB4AwAzgDgDADOAOAMAM4A4AwAzgDgDADOAOAMAM4A4AwAzgDg0vcJXA/b1H349sfoEV3m5avbH5+Kf18Ps9Txu+87/1+A/s4A4AwAzgDgDADOAOAMQJIkSZIkCeIXiVxyvkzeinoAAAAASUVORK5CYII=

" style="height: auto">

            </figure>

            <figure style="margin: 5px !important;">
              <img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAIAAAACACAYAAADDPmHLAAACQ0lEQVR4nO3cPUoDURRA4VHEVrKBrEBIm0XMLqawFLSwEURIY6HgAmYXWUTagCtIFiC2gmhvMVe4Pt7MnPO1mjAZDg/um5+mkSRJkiRJFCe1D6C03fLmO/P59eFl1ufotPYBqC4DgDMAOAOAMwA4A4AzALjJz7jZOT9r6vsErgBwBgBnAHAGAGcAcAYAZwBwZ9E/nD88FZ2zPx/vJj1HZ62666Lnd9+/Dp5fVwA4A4AzADgDgDMAOAOAMwC4cB9g7KLr8T4XMMwVAM4A4AwAzgDgDADOAOAMAK76PkC76opeD980H6nPt4uyx3cs+eV/4AoAZwBwBgBnAHAGAGcAcAYAl77WHT03EN33H12v3yxyc3xt9+8Xg3+P7jeInhuI7vuPuALAGQCcAcAZAJwBwBkAnAHAFb8fIJrzozm49PX40rLPLVw1X/97QL+4AsAZAJwBwBkAnAHAGQCcAcAV3weY+/P1WeH9AE3Z9wi6AsAZAJwBwBkAnAHAGQCcAcBVfz9AZLvvU/sIz32bmqNvu+2s9zFcAeAMAM4A4AwAzgDgDADOAOAmP+Nmnzuo/f21uQLAGQCcAcAZAJwBwBkAnAHAjX6GHfscPvbji7gCwBkAnAHAGQCcAcAZAJwBwFWfUac+R0fG/vtcAeAMAM4A4AwAzgDgDADOAOCKz6CXu2Xq+fy39WHS+wBj//2uAHAGAGcAcAYAZwBwBgBnAHDp9wRm51wNi85vdp/AFQDOAOAMAM4A4AwAzgDgDECSJEmSJAniBwaiZ8ssooQuAAAAAElFTkSuQmCC

" style="height: auto">

            </figure>

            <figure style="margin: 5px !important;">
              <img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAIAAAACACAYAAADDPmHLAAACHklEQVR4nO3csW0UQRiAUXOiBMdOIURCSPRACw4owTTgwA3QhFugByQnDiF1TExou4OdYLSaPX/v5T7vrT6N9M/ezsUFAAAAUPFu9QXs7d/D75eZv7/88vVN36PT6gtgLQHECSBOAHECiBNAnADizn7GnZ3zZ537PoEVIE4AcQKIE0CcAOIEECeAuPezH/Dp59/NOfzxx4eznpOP7un54+b9vzr92bz/VoA4AcQJIE4AcQKIE0CcAOKm9wFWGz2PP/p7AaM5fm9WgDgBxAkgTgBxAogTQJwA4g6/D3D99Dw1J98s/v/3V6fNfYTR8/rZ5/0jVoA4AcQJIE4AcQKIE0CcAOKW7wOMntdfDubo2Tl91mjOH36/xecLWAHiBBAngDgBxAkgTgBxAogbzqCj9/9njc4PWD3nz5rdJ/j/+fvm5/s9AFMEECeAOAHECSBOAHECiJt+Fr36nMDV+wSjOX+W9wLYlQDiBBAngDgBxAkgTgBxb/4s/9tv11P7BHe/7pfeI/sA7EoAcQKIE0CcAOIEECeAuOXnA8za+/37o7/fP8sKECeAOAHECSBOAHECiBNA3OFn2KPP4Ue/vhErQJwA4gQQJ4A4AcQJIE4Acctn1HOfo0eO/v2sAHECiBNAnADiBBAngDgBxAkgTgBxAogTQJwA4gQQJ4A4AcTtfj7A6Hl43erfC1gB4gQQJ4A4AcQJIE4AcQIAAAAAiHgF6TFyRKtznWQAAAAASUVORK5CYII=

" style="height: auto">

            </figure>

            <figure style="margin: 5px !important;">
              <img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAIAAAACACAYAAADDPmHLAAACWElEQVR4nO3dLU5DQRRA4cePIukCKqqRODbBBggCQUJShyaIBgFoHAqBIGwAhWITJAhURRdQgoUdvCtuJnfKOZ99NJ2Sk0lm3t8wSJIkSZIkiq3qAbT2svj5zXz++HrvX/+PtqsHoFoGAGcAcAYAZwBwBgBnAHAbv8bNrvOzWu8TrGb3qd83XV6Mjs8ZAM4A4AwAzgDgDADOAOAMAG43+oPr56um6+zFyc3G70VkZNf5Wc4AcAYAZwBwBgBnAHAGAGcAcOE+QO+i8/HV9wVE6/zofH3rfQJnADgDgDMAOAOAMwA4A4AzALjm+wDR+f71atb4fPh+6tPreW5834eprw/3CbKcAeAMAM4A4AwAzgDgDADOAODCfYBoHZ+9b+D14XP0+NE8t46v9n52Pnp89TikrhfIcgaAMwA4A4AzADgDgDMAOAOAa349QHRdfnTdffZ8fLXo9/l8AJUyADgDgDMAOAOAMwA4A4Brvg+Qvb9+Ml0W31cwLhpfJPt8gOz1As4AcAYAZwBwBgBnAHAGAGcAcBv/nMDbt4/iEUyKvz/HGQDOAOAMAM4A4AwAzgDgDACu+32Ay6d11/cFROO7O510/V5EZwA4A4AzADgDgDMAOAOAMwC4rteow9D/Orv38UWcAeAMAM4A4AwAzgDgDADOAODKrwfo/Xx/Vu/7BM4AcAYAZwBwBgBnAHAGAGcAcOX7AAdfO6PHs88ZbC1ax0fvS6jmDABnAHAGAGcAcAYAZwBwBgBX/t5Auux7FbOcAeAMAM4A4AwAzgDgDADOACRJkiRJkiD+AEjvb6Zc/WmHAAAAAElFTkSuQmCC

" style="height: auto">

            </figure>

            <figure style="margin: 5px !important;">
              <img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAIAAAACACAYAAADDPmHLAAACGUlEQVR4nO3cvWkcQRiAYckIVaFMIBDOlDpwdNW4AIfGoXtwJxcrVSYMBmWuwondwU4wLLOn93nyO3aXl4Fv9ufqCgAAAKi4Xn0Ae/vz+9O/md/fPTy/62v0YfUBsJYA4gQQJ4A4AcQJIE4AcRc/487O+bMufZ/AChAngDgBxAkgTgBxAogTQNzN7B98/Xi7OYf/eP170XPy0d2ffm1e/7fz4+b1twLECSBOAHECiBNAnADiBBA3vQ+w2uh+/NHfCxjN8XuzAsQJIE4AcQKIE0CcAOIEEDc94+79PMDL/WnpnDzr6e08df6z9/tHrABxAogTQJwA4gQQJ4A4AcQtfx5gdL/+7mF7jl69TzCa88fnt/b7AlaAOAHECSBOAHECiBNAnADihjPo6H7/rNHzAqvn/Fmz+wSfv/zc/H/PAzBFAHECiBNAnADiBBAngLjDvxcwsnqfYPa5/xHvBbArAcQJIE4AcQKIE0CcAOLe/bf8v51fpvYJvp+ell4j+wDsSgBxAogTQJwA4gQQJ4C45d8HmDV+/35ujj/6+/2zrABxAogTQJwA4gQQJ4A4AcQdfoY9+hx+9OMbsQLECSBOAHECiBNAnADiBBC3fEa99Dl65OjnZwWIE0CcAOIEECeAOAHECSBOAHECiBNAnADiBBAngDgBxAkgbvfvA4zuh9etfl7AChAngDgBxAkgTgBxAogTAAAAAEDEf1oKcIR9UagJAAAAAElFTkSuQmCC

" style="height: auto">

            </figure>

            <figure style="margin: 5px !important;">
              <img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAIAAAACACAYAAADDPmHLAAACT0lEQVR4nO3dIU4DQRSA4YUQkioUqCYcCFXbI2CwRaJaRULgAKjaXgHNDfBVuKoGDNxgXspj8rb5/882LbPkzyQzO9sOgyRJkiRJojipHkBkMp3/tF7fb9fNa4jeH8l+fvT+aqfVA1AtA4AzADgDgDMAOAOAMwC48jVqdh19dT9JrfOzPpf7o94ncAaAMwA4A4AzADgDgDMAOAOAO6seQP5+/uY/h3OwaHznz5fN9+9n7c+/2Nw1P383e0rtIzgDwBkAnAHAGQCcAcAZAJwBwJWfB+gte14gut8fidbxvUX7BM4AcAYAZwBwBgBnAHAGAGcAcOX7AKuLTek6ubfl61vz9Wid7nkAdWUAcAYAZwBwBgBnAHAGAFf+XMDj7bz5enQ/vnofYbGbtb+/4L32+wsizgBwBgBnAHAGAGcAcAYAZwBw3fcBonP5Y1/nR6LxLZbBPkHw//n6y6AO4AwAZwBwBgBnAHAGAGcAcAYAl34uILvOz6reJ4jOA2T5XIC6MgA4A4AzADgDgDMAOAOAS58H6L3Oj7zcfFT++WFY1/75LGcAOAOAMwA4A4AzADgDgDMAuPLvB1Bb9n5/xBkAzgDgDADOAOAMAM4A4AwArvz3AiLT+ap5Ln67XpRew9jHF3EGgDMAOAOAMwA4A4AzADgDgCtfox77Ojoy9utzBoAzADgDgDMAOAOAMwA4A4Arfy7g+/qheghdjf36nAHgDADOAOAMAM4A4AwAzgDgyn83kK769xacAeAMAM4A4AwAzgDgDADOACRJkiRJkiB+AWmweH/BwDwnAAAAAElFTkSuQmCC

" style="height: auto">

            </figure>

            <figure style="margin: 5px !important;">
              <img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAIAAAACACAYAAADDPmHLAAACcUlEQVR4nO3dMUoDQRSA4VUELxC2stJOrCzE3lNoY+MF0gjmABFs0gsWNjmBrYWthTdQLFKF3EEvIPMIw+Rl/f+vXaOb8DMwb3dj10mSJEmSJIqd7BNobTZa/NS8frw6+Nef0W72CSiXAcAZAJwBwBkAnAHAGQBc9R737OuzuM9+Pzxquo+u3efXGvqcwBUAzgDgDADOAOAMAM4A4AwAbi/6gWifX/v61nOCbP3kqvj+l9N56vt3BYAzADgDgDMAOAOAMwA4A4AL96C1c4Bon996TpD9XEA0B2gtmjO4AsAZAJwBwBkAnAHAGQCcAcClX4uP5gAv50+bOpUmTm6+i8ejfXrr+wlcAeAMAM4A4AwAzgDgDADOAODC5wJqRfv8y7P98i8YeKJ3jw/F4+NuvqEz+dvAP17VMgA4A4AzADgDgDMAOAOAaz4HiET33Y+D1y/7Sep99/1yGlyPnxaPRs8t3He3a5/TOlwB4AwAzgDgDADOAOAMAM4A4KrnAK2f78/e50ei84vmBNEcpO/afr+AKwCcAcAZAJwBwBkAnAHAGQBc+v0Akfh6e9n1x7JqH/182qd/h0JLrgBwBgBnAHAGAGcAcAYAZwBw1XOA1v/3L3sfn/33W3MFgDMAOAOAMwA4A4AzADgDgNv6+wHoav8fQMQVAM4A4AwAzgDgDADOAOAMAC79WvXQr7cP/fxdAeAMAM4A4AwAzgDgDADOAODS7wdYvB0Xj7+OV+mzipJoH38xG2319xy6AsAZAJwBwBkAnAHAGQCcAcA1nwNs+z44W/T5tJ6DuALAGQCcAcAZAJwBwBkAnAFIkiRJkiRB/AL473a8XbeA2QAAAABJRU5ErkJggg==

" style="height: auto">

            </figure>

            <figure style="margin: 5px !important;">
              <img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAIAAAACACAYAAADDPmHLAAACKklEQVR4nO3dMWoVQQCA4SgKgk1u4BXscpIUlnYBkZwliBBLQbDIETxBKm0t9QRphICF3uCNMKyzL//39W+ZffwMzOzseycnAAAAQMWj1QPY2u3d/Z+Zz5+dPnvQ39Hj1QNgLQHECSBOAHECiBNAnADijn6NO7vOn3Xs+wRmgDgBxAkgTgBxAogTQJwA4p7MXuDXi28H1+HPf7w86nXyQ2cGiBNAnADiBBAngDgBxAkgbnofYLXR83jvBRxmBogTQJwA4gQQJ4A4AcQJIG56jbv1eYDrm6ul5/5nXZxf7nofwQwQJ4A4AcQJIE4AcQKIE0Dc8vMAo+f1X798+F9D2cTo/kbnDW6uXh38/Pnl56l9BjNAnADiBBAngDgBxAkgTgBxwzXk6Hn/rGM/LzD7vH+0T/Dz4+uZyw/3CcwAcQKIE0CcAOIEECeAOAHEeS9gY6N9gtHz/ln2AThIAHECiBNAnADiBBAngLjd7wPMev/7emqd/ebpxdLxey+ATQkgTgBxAogTQJwA4gQQt+vfsPsXs+/fr77+amaAOAHECSBOAHECiBNAnADidr+G3fs6fO/jGzEDxAkgTgBxAogTQJwA4gQQt3yNeuzr6JG9358ZIE4AcQKIE0CcAOIEECeAuOX/G/jp+/3qIWxq7/dnBogTQJwA4gQQJ4A4AcQJIG7zfYC3t3dH/Xv/Wxt9P+/OTjc9L2AGiBNAnADiBBAngDgBxAkAAAAAIOIvoqlyFHTaZ5YAAAAASUVORK5CYII=

" style="height: auto">

            </figure>

            <figure style="margin: 5px !important;">
              <img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAIAAAACACAYAAADDPmHLAAACO0lEQVR4nO3dMUoDQRhA4VUC4gUsPICdKVJZxEoCtt4lvdjnFF4grRCsjClTRNJ4gBRewEbQG+yv/A4zy3tfm6xMlsfATCZr10mSJEmSJIqj2gOILLbj79pjyJhPdk3f4+PaA1BdBgBnAHAGAGcAcAYAZwBwBgBnAHAGAGcAcAYAZwBwBgBnAHBNf1f9G7P1oup5gdV03nsPz7/uesd3GC2LXh9xBoAzADgDgDMAOAOAMwA4A4Ab/D5AJLtPEK3zI9E6vrRon8AZAM4A4AwAzgDgDADOAOAMAK76PkDt7/NL21+99r7ueQBVZQBwBgBnAHAGAGcAcAYAN4recP/80bsOvT19SQ3g6fM6df3m5DF1fVZ0XiDa5zh0y/8d0B85A8AZAJwBwBkAnAHAGQCcAcCF+wClRfsI2X2C2rL7BPuu/zxBljMAnAHAGQCcAcAZAJwBwBkAXLgP8HBz1n/uPHleYOjr/KzscwaznAHgDADOAOAMAM4A4AwAzgDgqj8foLTt+DK1jp7s3qreI58PoKIMAM4A4AwAzgDgDADOAOCq/y4gKzpXP0k+7z/6+9n/J1CbMwCcAcAZAJwBwBkAnAHAGQBc82vY1tfhrY8v4gwAZwBwBgBnAHAGAGcAcAYAV32NOvR1dKT1z+cMAGcAcAYAZwBwBgBnAHAGAFd8DXoxW6d+n/++mg56H6D1z+8MAGcAcAYAZwBwBgBnAHAGAGcAcAYAZwBwBgBnAHAGAGcAcAYgSZIkSZIE8QPYW2pucxySUAAAAABJRU5ErkJggg==

" style="height: auto">

            </figure>

            <figure style="margin: 5px !important;">
              <img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAIAAAACACAYAAADDPmHLAAACP0lEQVR4nO3cMU4CQRSAYSSegsqOioLOmngJEo2tHZU9tV7AWk24hLG2p6Kj8hjqAUzmaR6Tmd3//1olDOTPJG/Y3clEkiRJkiRRnLVeQG37w9V35vWL+duov6Np6wWoLQOAMwA4A4AzADgDgDMAuMHPuNk5P2vo5wTuAHAGAGcAcAYAZwBwBgBnAHDnrRcwdqv1ffGc4n33WDxHyL4+4g4AZwBwBgBnAHAGAGcAcAYAN+jfsv+i9X0B0RxfW3RO4A4AZwBwBgBnAHAGAGcAcAYAlz4HuLn8LM65Lx+z4nu0vq6/ts12Wfy71wOoKQOAMwA4A4AzADgDgDMAuO7vC4h+j299jhCvb1Jc32J32vX8lzsAnAHAGQCcAcAZAJwBwBkAXHgOEP3eH4nm9KE/Zy+SPcfYbE+6nF/cAeAMAM4A4AwAzgDgDADOAOCqXw/wcPsc/Mes9hK6Fp0TrNbLqtc7uAPAGQCcAcAZAJwBwBkAnAHAhecA0f392ecDZEVz9N30NTVHP31dj/p6BXcAOAOAMwA4A4AzADgDgDMAuO6fDxCJ7zvIzfFjv6/BHQDOAOAMAM4A4AwAzgDgDACu+xm29zm89/VF3AHgDADOAOAMAM4A4AwAzgDgms+oQ5+jI71/PncAOAOAMwA4A4AzADgDgDMAuOoz6MX+kLo//7iYD/ocoPfP7w4AZwBwBgBnAHAGAGcAcAYAl34+QHbOVVn0/WbPCdwB4AwAzgDgDADOAOAMAM4AJEmSJEmSIH4Amr9wZD8yXy8AAAAASUVORK5CYII=

" style="height: auto">

            </figure>

            <figure style="margin: 5px !important;">
              <img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAIAAAACACAYAAADDPmHLAAACM0lEQVR4nO3doU7DUBSA4UFISCCYaQSuBoOZX/oSBL8geR4yT/DoapKFgMHMEAR6Diy8QY84NKfd/392Ge3Kn5vce7tuNpMkSZIkSRQH1ScQ6drtb/U5ZLRdM+prfFh9AqplAHAGAGcAcAYAZwBwBgB3VH0CWY9vX72vX1+dj/rvV3MEgDMAOAOAMwA4A4AzADgDgJv8OkAkmsfTOQLAGQCcAcAZAJwBwBkAnAHAjfqe9f+wmnep7xWsd+1eXyNHADgDgDMAOAOAMwA4A4AzALhwjnt/elL6/fyX46fKw6ctX+9Kj39z8d77P3YEgDMAOAOAMwA4A4AzADgDgEvvdUfrBLffP73HiPbro/347H5/Vvb8ovc/fF72vj+a50ccAeAMAM4A4AwAzgDgDADOAOAGfz5Adh48dfl1jGHvJ3AEgDMAOAOAMwA4A4AzADgDgBt8HWDf5/lZ0fVZzvrvB8hyBIAzADgDgDMAOAOAMwA4A4Cb/O8FfDyf1Z5AU3v4LEcAOAOAMwA4A4AzADgDgDMAuNGvA7TbTWo/vGsWqfsRouNHr2ePPzRHADgDgDMAOAOAMwA4A4AzALj0OkD0HEDlZJ8DGHEEgDMAOAOAMwA4A4AzADgDgCufw099Pz0y9s/nCABnAHAGAGcAcAYAZwBwBgA3+Bx0s5qn7utfrHeTXgcY++d3BIAzADgDgDMAOAOAMwA4A4AzADgDgDMAOAOAMwA4A4AzADgDkCRJkiRJgvgDU7pZGQNJyxMAAAAASUVORK5CYII=

" style="height: auto">

            </figure>

            <figure style="margin: 5px !important;">
              <img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAIAAAACACAYAAADDPmHLAAACXklEQVR4nO3doU7DUBhA4UJQVbg5FMkCweNmMCR4kqEwSAwGgUbMwRugWIIhewBMHX6GhBfAENSCgze4V/y5uW3P+ezSrltObvK3Xdc0kiRJkiSJYqv2AZTWteu/yPazzdGov6Pt2gegugwAzgDgDADOAOAMAM4A4AY/40bn/KjS5wmmT++hz/dxeZw8PlcAOAOAMwA4A4AzADgDgDMAuJ3oDm7nL8k5dbE8D83Juf03q8je64vO+VGuAHAGAGcAcAYAZwBwBgBnAHDha9nZOb2ys9VhaPvo9f7cnJ+7Xh/dPscVAM4A4AwAzgDgDADOAOAMAC58P0DfTa/vQ9t/NfPY8wVC7x6f83NcAeAMAM4A4AwAzgDgDADOAODC5wH2n9+Sr39enETfotcmi2VyTu/au+R5hKvC1/tzXAHgDADOAOAMAM4A4AwAzgDgRn8/QG253xVMG58PoIoMAM4A4AwAzgDgDADOAOBG/3yAm73Xqu+fu18gx+cDqCgDgDMAOAOAMwA4A4AzALjR3w/w/fsQ2v7gcTL4/1ZMcQWAMwA4A4AzADgDgDMAOAOAKz7jlr5fIPd/ANHn/XftOnn80f3X5goAZwBwBgBnAHAGAGcAcAYAV32GzZ0nKD3nRw39PIErAJwBwBkAnAHAGQCcAcAZAFz1GXXoc3RO3z+fKwCcAcAZAJwBwBkAnAHAGQBc8ecD7HZt+ncBp6WPoN9y38/PbOP/BqocA4AzADgDgDMAOAOAMwC44teis+cBMkrPwaX1/fO7AsAZAJwBwBkAnAHAGQCcAUiSJEmSJEH8AxIgay6/KH3BAAAAAElFTkSuQmCC

" style="height: auto">

            </figure>

            <figure style="margin: 5px !important;">
              <img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAIAAAACACAYAAADDPmHLAAACIElEQVR4nO3cMW7UQBiAUYNoiTjAlmk4AtoiNafYlmvlKBQRl9hyDwDhANBTrCMN1qz3e6+NInmtTyPN77GXBQAAAKh4N/sCtvZyuPwZ+f/j5XDX9+j97AtgLgHECSBOAHECiBNAnADidr/HHd3nj9r7nMAKECeAOAHECSBOAHECiBNA3IfZF8B1zw8fr845Tq+/h+YQVoA4AcQJIE4AcQKIE0CcAOJ2/Sz7LW79vYC1ff6otTmBFSBOAHECiBNAnADiBBAngLibnwM8Pj9MPfc/6nx6vXqPR+cAzgMwRABxAogTQJwA4gQQJ4C46e8FrD2vP56uP4+fPSdY2+ev/r6V8wZbnxewAsQJIE4AcQKIE0CcAOIEELf5HGB0H7x3a79v7f6cXz//3wv6hxUgTgBxAogTQJwA4gQQJ4C44T341vv82c/7R62dF1jjO4FsSgBxAogTQJwA4gQQJ4C4u34WvyzL8un749Ac4efTeeo9MgdgUwKIE0CcAOIEECeAOAHETf8+wKjV8whPY+cR7v29BitAnADiBBAngDgBxAkgTgBxNz8HmL0PH32//9bnBFaAOAHECSBOAHECiBNAnADips8B9r6P3vucwAoQJ4A4AcQJIE4AcQKIE0CcAOIEECeAOAHECSBOAHECiBNA3ObPor+8HIa+0/fjeLnp8wBrRn//t6+/rv7ddwIZIoA4AcQJIE4AcQKIEwAAAABAxF/ge2vm2vDnZQAAAABJRU5ErkJggg==

" style="height: auto">

            </figure>

            <figure style="margin: 5px !important;">
              <img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAIAAAACACAYAAADDPmHLAAACPklEQVR4nO3dMU4CQRSAYTReRL0HFTYaOmNBLIiNHZaewRJPYCMmtsSOit4j6FX0BvOiL8Nb+P+vhjC7+TPJzO6yo5EkSZIkSaI4qh5Ab+/r85/M92+mXwd9jo6rB6BaBgBnAHAGAGcAcAYAZwBw4Rp3vvhIraNfnq+6rqOz6/ysfd8ncAaAMwA4A4AzADgDgDMAOAOAO+n9A9E+Qu99gqHbzh6a52e8WjbPT/b7zgBwBgBnAHAGAGcAcAYAZwBw6TV4dp3fe59g6M8FROv4LPcB1GQAcAYAZwBwBgBnAHAGAFd+LT7aB7i9ft3VUEpMxquu1/sjzgBwBgBnAHAGAGcAcAYAZwBw5c8FXF4smt+fjNvX4zfbWen/A0Tr+Or/L4g4A8AZAJwBwBkAnAHAGQCcAcB13weIRPfdV6/zI9H40vsEb/8Y1B84A8AZAJwBwBkAnAHAGQCcAcCV/z9AVvU+QbTOz/K5AHVlAHAGAGcAcAYAZwBwBgBXfj9A1uf8rngEq+Lfz3EGgDMAOAOAMwA4A4AzADgDgNv7fYBDl73eH3EGgDMAOAOAMwA4A4AzADgDgCt/X0Dk6WzTvC/+8XtSegxDH1/EGQDOAOAMAM4A4AwAzgDgDACufI267+voyNCPzxkAzgDgDADOAOAMAM4A4AwArvy5gNPlffsD092Mo5ehH58zAJwBwBkAnAHAGQCcAcAZAFz3fYDwvXhw0fmJ3quY5QwAZwBwBgBnAHAGAGcAcAYgSZIkSZIE8Qu3sXG6+753IwAAAABJRU5ErkJggg==

" style="height: auto">

            </figure>

            <figure style="margin: 5px !important;">
              <img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAIAAAACACAYAAADDPmHLAAACJ0lEQVR4nO3cO4pUQRiA0faRNriA2cLk5u5E6KTB2FBcw8AkAy5EMDd3Cy5AmMRMc4OuoLzU7f7Oybunevgo+Os+DgcAAACg4sXqBWzt6fnuz8znT8efN/0/erl6AawlgDgBxAkgTgBxAogTQNzVz7izc/6saz8nsAPECSBOAHECiBNAnADiBBD3evYLfnz/dnEOv3/77qrn5FtnB4gTQJwA4gQQJ4A4AcQJIG76HGC10fX4vT8X8HB+3PR+hg+P54vrtwPECSBOAHECiBNAnADiBBC3+3OA1ff97/0cYTTnj9gB4gQQJ4A4AcQJIE4AcQKIW34OMJqzt77eP2t2fafj5Tl+6/sF7ABxAogTQJwA4gQQJ4A4AcQNzwFGz//Pfv7+eNvvD5g9J/j98f+u5192gDgBxAkgTgBxAogTQJwA4obnAKP3/HlP4JzROcHD+eB+ALYjgDgBxAkgTgBxAogTQNz0cwGr5/zRHP3p1/upOfrzmy83fY5hB4gTQJwA4gQQJ4A4AcQJIG75+wFmjeb82Tl+6+9fzQ4QJ4A4AcQJIE4AcQKIE0Dc7mfY1dfzV//9rdkB4gQQJ4A4AcQJIE4AcQKIWz6j3vr19r3/PjtAnADiBBAngDgBxAkgTgBxy58LuHv1dfUSNrX332cHiBNAnADiBBAngDgBxAkgbvNr0c9Pz1P31R9Px6u+H2Dvv98OECeAOAHECSBOAHECiBMAAAAAQMRfGodovULIE9sAAAAASUVORK5CYII=

" style="height: auto">

            </figure>

            <figure style="margin: 5px !important;">
              <img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAIAAAACACAYAAADDPmHLAAACTUlEQVR4nO3dMUoDQRhA4Siewy5nkFjbBjSFIJZW4gEUixSp9ABiZSmCRRQCVtYGbyCks4m30BvMFD+/O5v3vnZd2A2PgZndWQcDSZIkSZJEsdX1BWRbju9/I+ePFucb/Rttd30B6pYBwBkAnAHAGQCcAcAZAFzv57jReX5U39cJHAHgDADOAOAMAM4A4AwAzgDgdrq+AJU9P5wW1zmOzx5D6xCOAHAGAGcAcAYAZwBwBgBnAHC9XweoPY93X0CZIwCcAcAZAJwBwBkAnAHAGQBceB1gOD1IfS//9mk/dP76ax06fz6chu5vspo1vY7gCABnAHAGAGcAcAYAZwBwBgBXXQeIzvNvLvaKx6/uPovHL08+isej6wTZau8jdP2+gSMAnAHAGQCcAcAZAJwBwBkAXHUOmv28P7pO0PU6QPR5f23/f1Tt+wGOAHAGAGcAcAYAZwBwBgBnAHDp3weIzvM3XW2e7ncClcoA4AwAzgDgDADOAOAMAC59HSB7nl97Hv+6Ow89bz/8njS9vz/KEQDOAOAMAM4A4AwAzgDgDAAuPMfN3jewmr2H/h9AdP996/v7oxwB4AwAzgDgDADOAOAMAM4A4Jqfw7Y+D2/9+mocAeAMAM4A4AwAzgDgDADOAOA6n6P2fR5d0/r9OQLAGQCcAcAZAJwBwBkAnAHApX8foObn+q38B4v/uY4srd+fIwCcAcAZAJwBwBkAnAHAGQBc+jrAy3Kc+v2Avqv9PkejRer7Ao4AcAYAZwBwBgBnAHAGAGcAkiRJkiRJEH+pTGxaFQT18QAAAABJRU5ErkJggg==

" style="height: auto">

            </figure>

            <figure style="margin: 5px !important;">
              <img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAIAAAACACAYAAADDPmHLAAACTElEQVR4nO3cMU4CQRSAYTQaaht7GmOFJY2JhhNwDWNDzQGosTBcgxOYmNjQcgF6G2pioTfgFS/jzPD/X2tYds2fSd7ssoOBJEmSJEmiuKh9AqXtx9vfzOdHu8lZ/48ua5+A6jIAOAOAMwA4A4AzADgDgLuqfQJZ88P+9Jz/9F30+KubUdf7BK4AcAYAZwBwBgBnAHAGAGcAcN3vA0TePm9rn0LKcrg+uQ+xOL6k9iFcAeAMAM4A4AwAzgDgDADOAOC63weI7seHzwskj987VwA4A4AzADgDgDMAOAOAMwC4cB/g/WuamqMjr48fJ+fszXKY+/71ferjz8nvny2OTe8juALAGQCcAcAZAJwBwBkAnAHAhfsA0Zwe7RNEn4/u18+C+/HpfYKkaM5v/f0CrgBwBgBnAHAGAGcAcAYAZwBwxX8X0PocXFp0fdHv/yPZ9we4AsAZAJwBwBkAnAHAGQCcAcAV3wc49zk/K5rTfU+gijIAOAOAMwA4A4AzADgDgOv+PYHRc/nj7SZ1v303mVXdx8jO+RFXADgDgDMAOAOAMwA4A4AzALju79VHc352ji99/NpcAeAMAM4A4AwAzgDgDADOAOCan2Fbn8NbP7+IKwCcAcAZAJwBwBkAnAHAGQBc9Rm19zk60vr1uQLAGQCcAcAZAJwBwBkAnAHAVX8/wPTu4eTfd/90HqW0fn2uAHAGAGcAcAYAZwBwBgBnAHDF70X/zA+p9/Rdr266fh6g9et3BYAzADgDgDMAOAOAMwA4A5AkSZIkSYL4AzIdbykEvaPOAAAAAElFTkSuQmCC

" style="height: auto">

            </figure>

            <figure style="margin: 5px !important;">
              <img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAIAAAACACAYAAADDPmHLAAACXElEQVR4nO3coUqDURiA4U2Ma4LBIioYXTR4BQrGBe/ANsOa2WZZEe9hRRDcVVjMOrEsCLZ1vQH5v/BxPGe+71Pld2fj5cD5/u3v9SRJkiRJEkW/9gKy9lej75qvvxjM1voz3Ki9ANVlAHAGAGcAcAYAZwBwBgC3WXsBkeicfz56/qul/OoxWF/rcwJ3ADgDgDMAOAOAMwA4A4AzALjic4DtndvOc/LnctJ5Tl4dHne/wLDuHKD1c37EHQDOAOAMAM4A4AwAzgDgDAAufYaNzvm1XQzvUtdP54u1PudH3AHgDADOAOAMAM4A4AwAzgDgmv9dQG3j0/3UnKP1OYI7AJwBwBkAnAHAGQCcAcAZAFzxOcDWzUfn37+ud0svoajonB/NEaLr389eOq/fezpKzRncAeAMAM4A4AwAzgDgDADOAODSc4D/fs7Pys4JItk5gTsAnAHAGQCcAcAZAJwBwBkAXHoOEJ3zozlB9v+vu6v+Q9XXdweAMwA4A4AzADgDgDMAOAOA+/fPCVycvKauH8zuq/6+398FqCgDgDMAOAOAMwA4A4AzALjiZ9zSc4LonJ89x69Gl6n1154jRNwB4AwAzgDgDADOAOAMAM4A4Io/J/BzOek8B0dzguz9fHVzB4AzADgDgDMAOAOAMwA4A4Crfq86ut/e+v30SOvvzx0AzgDgDADOAOAMAM4A4AwArvj3ASLDndxzBFvX+vtzB4AzADgDgDMAOAOAMwA4A4ArPgc4GJ82/RzB2qLP5206L/p9AXcAOAOAMwA4A4AzADgDgDMASZIkSZIkiB9ZoGQtviT2vgAAAABJRU5ErkJggg==

" style="height: auto">

            </figure>

            <figure style="margin: 5px !important;">
              <img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAIAAAACACAYAAADDPmHLAAACX0lEQVR4nO3dIU4DQRSA4YUgMFTiSD13KIagSDDlAlW1oMCgMBBEsVUYbA22wdCTlCOAAAcXIPtIXpa35P8/29DONH8mmdnt0jSSJEmSJIlio3oAkdFi/lU9hozVeNrr73izegCqZQBwBgBnAHAGAGcAcAYA1+s96m8MB6PSc4L126rT7/DwYdY6v+fJeerzXQHgDADOAOAMAM4A4AwAzgDgtqoHEInuB3idPP7VUH4Ujc/7AdRrBgBnAHAGAGcAcAYAZwBwvT8HyO6js/cLRNf71+NV5u3LuQLAGQCcAcAZAJwBwBkAnAHApc8Bro8+Or0vf+fgpMu3/4WjTud3drUsvV/AFQDOAOAMAM4A4AwAzgDgDAAuPAeI9vkXl9upAdzefLa+/v7y1Pp6/TlBu9ld+/yquQLAGQCcAcAZAJwBwBkAnAHAhdeiu77en1V9DpC9nh89BzAreo6gKwCcAcAZAJwBwBkAnAHAGQBc+ncB0f0A0fV+umif7v8LUKcMAM4A4AwAzgDgDADOAODS5wDV+/y93ePSz2+aZfHn57gCwBkAnAHAGQCcAcAZAJwBwKWfUdf17wb2T+epvx9Pz1JzXMzvU/PLfn7XXAHgDADOAOAMAM4A4AwAzgDger1HbZp4H169z+77+CKuAHAGAGcAcAYAZwBwBgBnAHDle9T/vo+O9H1+rgBwBgBnAHAGAGcAcAYAZwBw5Xvs4WDUuk9ev63Kx5jR9/m5AsAZAJwBwBkAnAHAGQCcAcClnxMYifbBdNXnBK4AcAYAZwBwBgBnAHAGAGcAkiRJkiRJEN9O02kVd8qpGAAAAABJRU5ErkJggg==

" style="height: auto">

            </figure>

            <figure style="margin: 5px !important;">
              <img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAIAAAACACAYAAADDPmHLAAACGUlEQVR4nO3dIW5UURSA4ZYgcF0DO8BhCOsZgUCAQ+JAVtSzlRqwLIA11CFIiieEK05f7pT/+2wzfbeTPze5582bXlwAAAAAFZe7F3C0m7uX95PXn66+HvoeXd++H63vzatPo/U9mbyYx08AcQKIE0CcAOIEECeAuEc/B5ie86emc4LpHGBlNSewA8QJIE4AcQKIE0CcAOIEECeAOAHECSBOAHECiBNAnADiBBD3dPcCplb348/9uYDd7ABxAogTQJwA4gQQJ4A4AcRtnwPs/lz/ytHrO139+3P7Rz83YAeIE0CcAOIEECeAOAHECSBu+xxg5ej7/VO71+d7AhkRQJwA4gQQJ4A4AcQJIO7wOcDqHPy/f+5+Oif49f1h1/MnO0CcAOIEECeAOAHECSBOAHHjOUD9nD+1en+ub197LoDjCCBOAHECiBNAnADiBBA3ngPsPue/ffFt5+UfPTtAnADiBBAngDgBxAkgTgBxZ//9AM+eX47uh//8cT+aU6yuv/r59PpHswPECSBOAHECiBNAnADiBBB39nOAlaPP2avfP51T7GYHiBNAnADiBBAngDgBxAkgbvu96t33+6em6//85d1DLeWvVv9PwA4QJ4A4AcQJIE4AcQKIE0Dc4Wfojzd3o3Pyh9PV9lnFxLn//XaAOAHECSBOAHECiBNAnADiBBAngDgBxAkgTgBxAogTQJwAAAAAACJ+A8FKXP8B+hGJAAAAAElFTkSuQmCC

" style="height: auto">

            </figure>

            <figure style="margin: 5px !important;">
              <img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAIAAAACACAYAAADDPmHLAAACVUlEQVR4nO3bMU4CQRSAYTR7BAsrY8EtxCsYGgsqPQOxwMKeijPYWRAT4hmw8gA2VNp4CBItLUxmDM/JW/z/ryUsw+bPJPNYBgNJkiRJkkRxkL2A1jbd4jPy/uF2+q/v0WH2ApTLAOAMAM4A4AwAzgDgDACuy15A7ZxeO4fX3n99ebHLsr6vvxw0Xd/N6eMuy/q11ea5uD53ADgDgDMAOAOAMwA4A4AzALje/9bd+pwfdb98Kr7e+pxf4xxARQYAZwBwBgBnAHAGAGcAcL2fA0SNJpvQ/wLWD8PQPRoPz0KfH+UcQEUGAGcAcAYAZwBwBgBnAHC9nwPMx8PUc3TUbLUp3uPWcwLnACoyADgDgDMAOAOAMwA4A4BLnwPUfq+v/R6fPSeonfOj3682J6id82vcAeAMAM4A4AwAzgDgDADOAOCazwH2/ZwfFZ0THL1cFa/vHEAhBgBnAHAGAGcAcAYAZwBw4TlA9JwflT0nqJ3zo3weQE0ZAJwBwBkAnAHAGQCcAcCl/y+gtW4xD80JttNZ6j1yDqCmDADOAOAMAM4A4AwAzgDguuwFRFWfR5jGnkfIft6hNXcAOAOAMwA4A4AzADgDgDMAuN7PAbLP4bXrZ68vyh0AzgDgDADOAOAMAM4A4AwALn0OsO/n6H2fE7gDwBkAnAHAGQCcAcAZAJwBwKXPAehq//9vzR0AzgDgDADOAOAMAM4A4AwALjwHuB1NYufY97viy+vQxfOdV77f4Pik+PLrx9sfruYndwA4A4AzADgDgDMAOAOAMwBJkiRJkiSIL1lQhqzNanTvAAAAAElFTkSuQmCC

" style="height: auto">

            </figure>

            <figure style="margin: 5px !important;">
              <img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAIAAAACACAYAAADDPmHLAAACNklEQVR4nO3dIW5UURSA4UIQKAwrQI7BsgQS2AAkoGEN7IMENAg20CZodlBTWYNFgMLBDuZCLjeX6f99dtLOS/PnJOf2zZuzMwAAAKDi1u4LWO3i6tWvmZ9/cnh/o/9Gt3dfAHsJIE4AcQKIE0CcAOIEEHfyO+7snj/r1M8JTIA4AcQJIE4AcQKIE0CcAOLu7L6Am+7pvWdHzynOf3zaeo5gAsQJIE4AcQKIE0CcAOIEEHfS/8v+E7s/FzA6B1htdM5gAsQJIE4AcQKIE0CcAOIEELf8HODlg49L9+DnF19W/vppbx99P/r6aE9ffT+BCRAngDgBxAkgTgBxAogTQNzwcwGr9/jD49dHX7/6/G7l208b3S8wuh/h/PBvr+dvmQBxAogTQJwA4gQQJ4A4AcRNPx9gtMfXzZ4TjO4nmGUCxAkgTgBxAogTQJwA4gQQ5zmBm43OCVY/X8AEiBNAnADiBBAngDgBxAkgbvocYPd9+6M9+vLnt6k9+uHd+zf6WYomQJwA4gQQJ4A4AcQJIE4AcdM77urnB3y4frF0z5916ucEJkCcAOIEECeAOAHECSBOAHHbvy9g9Z4/u6fvfv/VTIA4AcQJIE4AcQKIE0CcAOK276invmef+vWbAHECiBNAnADiBBAngDgBxG1/TuDX6zdHXx99/n+30R4/+j6A3UyAOAHECSBOAHECiBNAnADilp8D/O978G6jv8/qcxATIE4AcQKIE0CcAOIEECcAAAAAgIjfkB9k6AXYPdcAAAAASUVORK5CYII=

" style="height: auto">

            </figure>

            <figure style="margin: 5px !important;">
              <img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAIAAAACACAYAAADDPmHLAAACXElEQVR4nO3dMU4CQRhAYTR4Cwp7Y0WBJhxAC6OljaUFhYUJjR0dhSQWJnIAj2CBByBRCu28gbeQRG+wk/AzzsB7X0uAZfMyyT+wS6slSZIkSZIodkofQFR/Ofwt+f7z9mSjz+Fu6QNQWQYAZwBwBgBnAHAGAGcAcMVn2Ogc/3Pzvq5DWcne41Ho+aX3EVwB4AwAzgDgDADOAOAMAM4A4NqlDyA1B5f+vj+q9Jyf4goAZwBwBgBnAHAGAGcAcAYAV/WMug69QT+0j7CYzrf6HLkCwBkAnAHAGQCcAcAZAJwBwIVn3NPvq6zf1/euxzlfPrvRrFP1PoIrAJwBwBkAnAHAGQCcAcAZAFxyRo3O+Q9fZ5Gnt24PXhofr32fYLZ/2fh46vcG49e3xvN/d3Ic2mdwBYAzADgDgDMAOAOAMwA4A4AL3x8gNeen5vhtl5rzo9ctRPcJXAHgDADOAOAMAM4A4AwAzgDgit8nkO7i/L7o+7sCwBkAnAHAGQCcAcAZAJwBwGW/LiC3Wee58TMsh6PQ8bcno6LX93tdgLIyADgDgDMAOAOAMwA4A4BL/h4gNWfn3idIvX/qd/XROT71+pv+fwKuAHAGAGcAcAYAZwBwBgBnAHDVz7C1z+G1H1+KKwCcAcAZAJwBwBkAnAHAGQBc8Rl10+folNo/nysAnAHAGQCcAcAZAJwBwBkAXPH7BD59HjY+3m3N/+lI8qj987kCwBkAnAHAGQCcAcAZAJwBwIX3AT56g6rvI1i76PnrLqbeJ1CrMwA4A4AzADgDgDMAOAOQJEmSJEmC+AP5lGhDbprreQAAAABJRU5ErkJggg==

" style="height: auto">

            </figure>

            <figure style="margin: 5px !important;">
              <img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAIAAAACACAYAAADDPmHLAAACSElEQVR4nO3dMUoDURRA0VEMpBAsXICQIuACLOwi7iSbCLgAIZtwJ2J2IaYIxEKwsBAsAhF0B3nF4/Nmcu/pM5mEy4f355N0nSRJkiRJojipvoHWNovZX+b1k+XqqL+j0+obUC0DgDMAOAOAMwA4A4AzALiz6huIZOf4u4en3Pt389J9hN368uD7j6dfqeu7AsAZAJwBwBkAnAHAGQCcAcD1fh8gkp3zs9d/eZynrh/N+dnXR/sErgBwBgBnAHAGAGcAcAYAZwBw4bPkn+v71JwaOX99bnru/up7k7r/7cWk9Hm+5wHUlAHAGQCcAcAZAJwBwBkAXO/PA4x269Qc/9H9lr5/936benl2zo+4AsAZAJwBwBkAnAHAGQCcAcClZ8zovED0vD96Xh89j0/P6Un78TT1+d4+bw5e330ANWUAcAYAZwBwBgBnAHAGANf8PEB2zh+68PMlfx8gyxUAzgDgDADOAOAMAM4A4AwArvk+QHbOr37eH4nuLzov4O8DqJQBwBkAnAHAGQCcAcAZAFzvfx8gmqMji9kotY+wXO2P+ryCKwCcAcAZAJwBwBkAnAHAGQDc4GfcaM7PzvGtr1/NFQDOAOAMAM4A4AwAzgDgDACu9+cBss/zWxv6PoErAJwBwBkAnAHAGQCcAcAZAFz5jDr0c/tDv39XADgDgDMAOAOAMwA4A4AzALjyfYBj/z+Bvn8+VwA4A4AzADgDgDMAOAOAMwC48v8NpKveJ3AFgDMAOAOAMwA4A4AzADgDkCRJkiRJgvgH6EuFW7i97GkAAAAASUVORK5CYII=

" style="height: auto">

            </figure>

            <figure style="margin: 5px !important;">
              <img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAIAAAACACAYAAADDPmHLAAACRklEQVR4nO3dIU4DQRhA4YUQTtAjYCqqKpaTlDtUESQHQDZV3ADRnoQVGwQChUWhEIgaOADJTODv5G9577Obbaebl0lmdhe6TpIkSZIkUZxkD6C11XT5FTn/5uX+X1+j0+wBKJcBwBkAnAHAGQCcAcAZANzRr3Gj6/yo2j7BYn6dOr7tuC6OzxkAzgDgDADOAOAMAM4A4AwAzgDgDADOAOAMAM4A4AwAzgDgDADuLHsAUbX78b4XUOYMAGcAcAYAZwBwBgBnAHAGAJe+D9Av5k2fm990Q+j8fhYc32vo7OacAeAMAM4A4AwAzgDgDADOAODS9wGunvvi8c0sto7Pdvm5Kx6P/n2B2vv/Nc4AcAYAZwBwBgBnAHAGAGcAcM33AWrP5Vefu38pf37r5wlqhu1YHP/QjcXza9fn8Q9j+g1nADgDgDMAOAOAMwA4A4AzALjwPkB4nQ+X/f8GnAHgDADOAOAMAM4A4AwAzgDgwvsA2ev8p4v0VxuOmjMAnAHAGQCcAcAZAJwBwBkA3MEvos9v+9D98N3dENqnqH1/7Xj0+1tzBoAzADgDgDMAOAOAMwA4A4A7+H2Amtbr7NrnR/cpsjkDwBkAnAHAGQCcAcAZAJwBwKXvAxz7/fToPkH273MGgDMAOAOAMwA4A4AzADgDgGu+D/C+mlbul38Uj072OJYMb5Py7+sq12f5sM/R/OQMAGcAcAYAZwBwBgBnAHAGAJf+PIDKtuO66fMCzgBwBgBnAHAGAGcAcAYAZwCSJEmSJEkQ32E3YDBfSRDpAAAAAElFTkSuQmCC

" style="height: auto">

            </figure>

            <figure style="margin: 5px !important;">
              <img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAIAAAACACAYAAADDPmHLAAACZ0lEQVR4nO3doUoEURSA4VEMdrGYxCYYDOIrCCIbxS7YTAZBxCgYNtkEuxj3McRg2CaISRCx2/QBlHvAs+O96/9/dXB3dvi5cO7Ojl0nSZIkSZIoZmqfQN/W3jc+M38/Xrj/19dotvYJqC4DgDMAOAOAMwA4A4AzALjqM240p0dz+OBoLTXnZ42G4+L5ZT9f31wB4AwAzgDgDADOAOAMAM4A4KrvA0SiOXrl/OOvTuVHTyfzxeN9z/l3V4vF67N58FZ8f1cAOAOAMwA4A4AzADgDgDMAuOb3AbKy9wtE3/dnRXN8lvsAKjIAOAOAMwA4A4AzADgDgGt+H6D2ff9Z2X2E7Pf9EVcAOAOAMwA4A4AzADgDgDMAuLnsCzwcPqfm9Jeb3eLx7eHdVD8fIDq/vu83iLgCwBkAnAHAGQCcAcAZAJwBwIX7ANk5P7K0d1t+/64rvv9ZtzPJ05m47D5B171O8nS+cQWAMwA4A4AzADgDgDMAOAOAS98PEH2fH835kfXL5abvB8iK9glOe35+gCsAnAHAGQCcAcAZAJwBwBkAXPPPB8h639hPzdEL99dVr5HPB1CvDADOAOAMAM4A4AwAzgDgpn4foO/f37f++/4sVwA4A4AzADgDgDMAOAOAMwC45mfY1ufw1s8v4goAZwBwBgBnAHAGAGcAcAYAV31GnfY5OtL653MFgDMAOAOAMwA4A4AzADgDgDMAOAOAMwA4A4AzADgDgDMAOAOAS/+/gOPBUe559o/lw6NunHr52lYft8rHB1up63cxGvqcQP2eAcAZAJwBwBkAnAHAGYAkSZIkSRLEF7+TebMDi4bdAAAAAElFTkSuQmCC

" style="height: auto">

            </figure>

            <figure style="margin: 5px !important;">
              <img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAIAAAACACAYAAADDPmHLAAACGElEQVR4nO3dMW5TQRRAURNlAWnpUlJnI9kGHT0LYA1sI2If1JTpaM0GgAUgeYQmX8/JPaeNvv2TXI00z2P7dAIAAAAq3k3fwMrj3fOfSz9/Ot9f/B1W16/sPv7q+mk30zfALAHECSBOAHECiBNAnADixveou/vom5+PW/v8Xb/fPx06J/j84+PF6798+Lr1P7QCxAkgTgBxAogTQJwA4gQQdzt9A7uvt387fXrZG/pP0+cBducEVoA4AcQJIE4AcQKIE0CcAOLGzwMcbfe8wOr1/qM5D8ChBBAngDgBxAkgTgBxAogbnwNMn+uftpozrOYAK84DcJEA4gQQJ4A4AcQJIE4AcePvC1hZ7ZOn5wjT9+c8AFsEECeAOAHECSBOAHECiDt8DrDaB0+fuz/a9pzg14vezr/Pf+zDc+0EECeAOAHECSBOAHECiNueA9T3+buWf5/N9wWsWAHiBBAngDgBxAkgTgBxAojbngNM7/NXz3/3/LC1jz7ff3/TcwwrQJwA4gQQJ4A4AcQJIE4AcVf/+QArq/MI5805xVs/72AFiBNAnADiBBAngDgBxAkg7urnANP78N3391/7nMAKECeAOAHECSBOAHECiBNA3Pgc4LXvo1/7nMAKECeAOAHECSBOAHECiBNAnADiBBAngDgBxAkgTgBxAogTQNz49wbW+d5ARgkgTgBxAogTQJwA4gQAAAAAEPEXHSp8xk+65s8AAAAASUVORK5CYII=

" style="height: auto">

            </figure>

            <figure style="margin: 5px !important;">
              <img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAIAAAACACAYAAADDPmHLAAACeklEQVR4nO3cMUpDQRRA0URs7NJYxM5W7URQBLtYugARRFyEa3ARIjb2tqYTBEHSqUvQNp1lLG1knvr4zsR7Txt+8hMuA28cf68nSZIkSZIo+rVvIOt4ejGr+flXg9O5/g0Xat+A6jIAOAOAMwA4A4AzADgDgGt+ho3m/Kf3u7+6lS9tLO0VX299n8AVAM4A4AwAzgDgDADOAOAMAK7pGfU7Nt+Oq54HmAyvOv0NL7cGxe938jhNfb4rAJwBwBkAnAHAGQCcAcAZANzc7wNEsvsEtef8rGifwBUAzgDgDADOAOAMAM4A4AwAbjH7Bv3xa3GOnY1WinNodP3z/vNvbuvTSu7yXv8oNaevzUad7iN4HkApBgBnAHAGAGcAcAYAZwBw4T5ANKdHdpZXi9c/BNev364XX0/vE3QsOo9wEpw36Pq8gCsAnAHAGQCcAcAZAJwBwBkAXPo8wPbhbvH1h+v77Ec0Lfx7/7B8ffh/Cwc3P72lH3EFgDMAOAOAMwA4A4AzADgDgEvvA2Tn/HnfR3jpj4tzfLRPED5/wPMA6pIBwBkAnAHAGQCcAcAZAFx6HyArO+dHc/b04iU1Rw9O1/71sxRdAeAMAM4A4AwAzgDgDADOAODSM272+QGR6DmD0bn67PP+u37/2lwB4AwAzgDgDADOAOAMAM4A4JqfYVufw1u/v4grAJwBwBkAnAHAGQCcAcAZAFz1GXXe5+hI69/PFQDOAOAMAM4A4AwAzgDgDACu+ox9vvlWnJPPJsPq95jR+vdzBYAzADgDgDMAOAOAMwA4A4Dr/DmB0RxMV3ufwBUAzgDgDADOAOAMAM4A4AxAkiRJkiQJ4gNvFX0I0jXyJQAAAABJRU5ErkJggg==

" style="height: auto">

            </figure>

            <figure style="margin: 5px !important;">
              <img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAIAAAACACAYAAADDPmHLAAACM0lEQVR4nO3dMU4CQRSA4dVoa284i6cwQM8BtvAeWNBrDxzDsxB7EysLvMG+kMfkzfL/X0sIw+bPJG9YYBgkSZIkSRLFXfUCWjsuDufM85en1U1fo/vqBaiWAcAZAJwBwBkAnAHAGQBc+YybndO/3mvfwstbavnl5wzuAHAGAGcAcAYAZwBwBgBnAHAP1QvIzsHjcMwN4knR+v8+n6fXt7nqci7mDgBnAHAGAGcAcAYAZwBwBgBXfj9Aa+M+d06wWy9T1yg8B2jscfM9uX53ADgDgDMAOAOAMwA4A4AzALjuzwGyc3y17e84+Xg0p0fnCNHzI+4AcAYAZwBwBgBnAHAGAGcAcOXfC4jm/Ojz+OpzgvB+gXB9yyuu5nLuAHAGAGcAcAYAZwBwBgBnAHDNzwGyc/7cpc8xgvsJstwB4AwAzgDgDADOAOAMAM4A4NLnAPQ5Pyu6PtvGvy/gDgBnAHAGAGcAcAYAZwBwBgB38zP64vCUmqNPq5/Sa+TvA6gpA4AzADgDgDMAOAOAMwC42Z8DZOf8rOpzgix3ADgDgDMAOAOAMwA4A4AzALjuZ9jqz/OrX781dwA4A4AzADgDgDMAOAOAMwC48hk1mrN7n6Mjvb8/dwA4A4AzADgDgDMAOAOAMwC48v8NfD1/TD6+K/5fvaze3587AJwBwBkAnAHAGQCcAcAZAFz6s+jFuG/6/fzTbj3v+wE6vz7uAHAGAGcAcAYAZwBwBgBnAJIkSZIkSRD/iZFraNn6AMAAAAAASUVORK5CYII=

" style="height: auto">

            </figure>

            <figure style="margin: 5px !important;">
              <img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAIAAAACACAYAAADDPmHLAAACUElEQVR4nO3dMU4CURRAUTQkmFhYGSp2QUlkBXRaWRkLS0PhKiyoLViBdqxAQklhYmPCCogbgEp3MC/x+fMH7j0tkRkmNz95PzNjpyNJkiRJkihOap9AaaPF7Cfz96vJ9Kiv0WntE1BdBgBnAHAGAGcAcAYAZwBw1WfcaE6P5vDsnJ+VPb/a+wyuAHAGAGcAcAYAZwBwBgBnAHDV9wGyhv1R1X2A9XZV9Bp+L98af9/l1XXq+K4AcAYAZwBwBgBnAHAGAGcAcN3aJ5AVzeHZfYLSc35trgBwBgBnAHAGAGcAcAYAZwBwrd8H6O3mqTn+M3v8zl3q+Puz+1bvI7gCwBkAnAHAGQCcAcAZAJwBwKX3AXbzTWpOfnm+afz8MZijs/sEWdGcH92PUPt+A1cAOAOAMwA4A4AzADgDgDMAuHAGLT3nRx6eXhs/v7hdpr6/tGifIHr+Pyt6f4ArAJwBwBkAnAHAGQCcAcAZAFzxfYBIeD/A18dB3w+Q5XsCVZQBwBkAnAHAGQCcAcAZAFyrn13/D4tZL7VPMJnuj/oauQLAGQCcAcAZAJwBwBkAnAHAHfyMW/r5+7Y/35/lCgBnAHAGAGcAcAYAZwBwBgDX+hm27XN4288v4goAZwBwBgBnAHAGAGcAcAYAV31GPfQ5OtL23+cKAGcAcAYAZwBwBgBnAHAGAGcAcAYAZwBwBgBnAHAGAGcAcAYA181+wXjYT76vf9P88Tb37bWdD5p/33iQu37v663/L0B/ZwBwBgBnAHAGAGcAcAYgSZIkSZIE8Qsk7HOQjgXOTAAAAABJRU5ErkJggg==

" style="height: auto">

            </figure>

            <figure style="margin: 5px !important;">
              <img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAIAAAACACAYAAADDPmHLAAACEklEQVR4nO3dsU0cQRiAUbAsJ27CGel1QEgB1jVBIa4A0QRyAYQkjknJ3IQTJ3YHO4jRanfvey8/aW/0aaR/dg6urgAAAICK660fYG0v99//zXz+9vHnRa/Rp60fgG0JIE4AcQKIE0CcAOIEEHf4GXd2zp919HMCO0CcAOIEECeAOAHECSBOAHGft34A5pxPb4vnIE+vN4vnFHaAOAHECSBOAHECiBNAnADiDv0u+z32/ruA0Rw/yzkAiwQQJ4A4AcQJIE4AcQKI2/05wN35tOm9/1nPT6+Lazx7DjCa80fsAHECiBNAnADiBBAngDgBxG3+u4DR+/rR+/itzwlGc/74+y3P8WvfF7ADxAkgTgBxAogTQJwA4gQQt/o5wNHn/JHR842+32h9Hn595Knezw4QJ4A4AcQJIE4AcQKIE0Dc9DnA7JxfN1qf8+mH+wCsRwBxAogTQJwA4gQQJ4C4i5/Rv/29m5qjf3953nSNZv8fwIgdIE4AcQKIE0CcAOIEECeAuMOfA6x9H+HS7zvYAeIEECeAOAHECSBOAHECiNv9DLv3OXzvzzdiB4gTQJwA4gQQJ4A4AcQJIG7zGfXoc/TI3r+fHSBOAHECiBNAnADiBBAngDgBxAkgTgBxAogTQJwA4gQQJ4C46XfRf17uV/179l9vHw99H2Dv62MHiBNAnADiBBAngDgBxAkAAAAAIOI/DiBnNCTPkTwAAAAASUVORK5CYII=

" style="height: auto">

            </figure>

            <figure style="margin: 5px !important;">
              <img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAIAAAACACAYAAADDPmHLAAACaElEQVR4nO3dMUoDURRA0UTsTKFLcAEp0lgoLkB7G7FLCkFRIS5DQQQ709qIrWAt1imyALdgkcJOFyDMK14+f8Z7TytJhnD58J7JpNeTJEmSJEkU/doXkLX4Wv7UfP3h5qDT7+Fa7QtQXQYAZwBwBgBnAHAGAGcAcK2fYWvP+Vlt3xN4AsAZAJwBwBkAnAHAGQCcAcCt176ArLvrz6qvf3WzXfT557d7jXuQ0fQjtWfwBIAzADgDgDMAOAOAMwA4A4Br9f+qV2E8WaQ+TzB7HBZ9j6I5PyvaE3gCwBkAnAHAGQCcAcAZAJwBwKU/D/D6PGucYw+Pxo1zaPT4yMvbTubhobbvEbI8AeAMAM4A4AwAzgDgDADOAODCPUB2Tj+52Oj09/sj0Zwf7RFG0+bH+70AFWUAcAYAZwBwBgBnAHAGAJf+PMDT+0XRxx/v36eev7bsnqDXO13l5fzhCQBnAHAGAGcAcAYAZwBwBgBX/D6BXZ/jS4v2BOeF7x/gCQBnAHAGAGcAcAYAZwBwBgCX3gPUnvOjOfpr+ZCaozcHZ63+fn+WJwCcAcAZAJwBwBkAnAHAGQBcuAcofZ+/yO7Bd+Pfozk/O8f/9z2CJwCcAcAZAJwBwBkAnAHAGQBc8Rk1+3sCtefw2q9fmicAnAHAGQCcAcAZAJwBwBkAXPUZtetzdtev3xMAzgDgDADOAOAMAM4A4AwArvh9AiNbl/PGv//MHqvvKppEc3x/PGn17yZ6AsAZAJwBwBkAnAHAGQCcAcAV3wO0fQ6uLXp/Su9BPAHgDADOAOAMAM4A4AwAzgAkSZIkSZIgfgHFUnPVo96xVwAAAABJRU5ErkJggg==

" style="height: auto">

            </figure>

            <figure style="margin: 5px !important;">
              <img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAIAAAACACAYAAADDPmHLAAACeElEQVR4nO3dPUoDURRA4SiuQC0sg2BlmUYRSwsRQbAULIK4gIClFi4gCxBxDeksrEWblFaCpLSxt9MdvCtcH/OGc742JDMJhwd3Mj+DgSRJkiRJoljqegcii+f5T9f7kDHcGzX9Gy93vQPqlgHAGQCcAcAZAJwBwBkAXNMz6l9sbC+Kxwle775Sn79zuVZ8/fNt2Ovf0BUAzgDgDADOAOAMAM4A4AwArvkZNjofIJrTa4uOM3g+gJpmAHAGAGcAcAYAZwBwBgDX9Iz6H6LzBSJ9/78/4goAZwBwBgBnAHAGAGcAcAYAF864J5On1Bw9mx4UtzE/mfT6+v/I0fpZp9v/vC+fj+AKAGcAcAYAZwBwBgBnAHAGALeS/YCH99vy68f7xTl/vHmY2v71x2Pq/dW95O4vsHFRvi4imvMjrgBwBgBnAHAGAGcAcAYAZwBw6eMA462b1Puj4wjZz69tNJsGc/i0+Gp83ULuPocRVwA4A4AzADgDgDMAOAOAMwC46ucDRFqf82sLzwfYrfvcRFcAOAOAMwA4A4AzADgDgDMAuM7PB8j6vu72+vvBrPx/f+tcAeAMAM4A4AwAzgDgDADOAODS98LP3kcwcnW2mnr/3ih3/fzzPPd/fHb73h9AVRkAnAHAGQCcAcAZAJwBwFV/Jl50nCB6nkA0h2fn7KzW9y/iCgBnAHAGAGcAcAYAZwBwBgDX+Yza9zk60vr3cwWAMwA4A4AzADgDgDMAOAOAS98fIOv0vPxcvb5r/fu5AsAZAJwBwBkAnAHAGQCcAcBVPw4QPxePLfp9oucJZLkCwBkAnAHAGQCcAcAZAJwBSJIkSZIkQfwCxmZpakCPNxIAAAAASUVORK5CYII=

" style="height: auto">

            </figure>

            <figure style="margin: 5px !important;">
              <img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAIAAAACACAYAAADDPmHLAAACGklEQVR4nO3dMW7TUBzAYYOqSLAwdK44CVvPUokzMHOGSD1Ltx6DCTEzsIDUBQ5QyW94WHby+749iR399KT/s50sCwAAAFDxZu8D2NqPz1//zrz+7vzlqr+jt3sfAPsSQJwA4gQQJ4A4AcQJIO7iZ9zZOX/Wpe8TWAHiBBAngDgBxAkgTgBxAoi7mX2Dnx9+r87ht7/eX/ScfO2sAHECiBNAnADiBBAngDgBxE3P6EffB/BcwDorQJwA4gQQJ4A4AcQJIE4AcYffB3h4ud/1vv9Zj6en1fN/uf++6fmdnj6ufr4VIE4AcQKIE0CcAOIEECeAuOnnAmaNrtffndavx++9TzCa80fndzqvz+mjfYLRnD9iBYgTQJwA4gQQJ4A4AcQJIG64DzC63j/7+tvzdf9+wOi5guFzC9/+6+G8YgWIE0CcAOIEECeAOAHECSDOcwEbG90vMOJ+ADYlgDgBxAkgTgBxAogTQNxVX4tflmX59Odhah/h+d3jrt+RfQA2JYA4AcQJIE4AcQKIE0Dcxe8DDH9fYPL3/rd+/71ZAeIEECeAOAHECSBOAHECiDv8DHv0OfzoxzdiBYgTQJwA4gQQJ4A4AcQJIG73GfXS5+iRo5+fFSBOAHECiBNAnADiBBAngDgBxAkgTgBxAogTQJwA4gQQJ4C44f8Gzhr+L17c3vcLWAHiBBAngDgBxAkgTgBxAgAAAACI+AeGcW4epZDnaQAAAABJRU5ErkJggg==

" style="height: auto">

            </figure>

            <figure style="margin: 5px !important;">
              <img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAIAAAACACAYAAADDPmHLAAACmElEQVR4nO3dIUsEURRAYV1s/gWDdZENNhGLUQSLwWA2GiwWjYvBajQIgnGjWcMigsEgYhVZ7ApW9Qco7yJ3Z9/IOV9dZ+aNHh68cWZ2akqSJEmSJFFM1x5AZOVh9qv0+bD3UTyHaPtIdv/R9rV1ag9AdRkAnAHAGQCcAcAZAJwBwM3UHkAkWkfPLa0E6/z71PGj/Q97w1av8yPOAHAGAGcAcAYAZwBwBgBnAHCtX8NG/29/3lmc1FB+NX9avs5wc31e/Pxzd7P4N+icDIrnH20fcQaAMwA4A4AzADgDgDMAOAOAa/11gKz4foGy0W3u//3ROr5p4XWGSQ1E7WQAcAYAZwBwBgBnAHAGABc+F9A9viyuY5/211Pr5MPucbPr5Lfk9t2N1PiOgs+9H0BVGQCcAcAZAJwBwBkAnAHApd8P8Hl3UFynLlwtF7cfJI+/efaY3ENO/2m//P6Ci/L9CKPxDufPnAHgDADOAOAMAM4A4AwAzgDg0tcBonV+5HH1ptH91xY9VxA9t/A63uH84AwAZwBwBgBnAHAGAGcAcAYAl74OkF3H//d1flZ0naCzvdfocxPOAHAGAGcAcAYAZwBwBgBnAHDV7wfI2np5r3r8ftWj5zkDwBkAnAHAGQCcAcAZAJwBwKW/LyB6j2BW9B7Ch9nD4vF7H/3UOTa9/9qcAeAMAM4A4AwAzgDgDADOAOAaX8Nmv2+g7evwto8v4gwAZwBwBgBnAHAGAGcAcAYAV32N+t/X0ZG2n58zAJwBwBkAnAHAGQCcAcAZAFz6/QBZa73r8g/cTmQYjWn7+TkDwBkAnAHAGQCcAcAZAJwBwDV+HSD6Xjy66PcTfZ9AljMAnAHAGQCcAcAZAJwBwBmAJEmSJEkSxDe7gYKmDpBVIwAAAABJRU5ErkJggg==

" style="height: auto">

            </figure>

            <figure style="margin: 5px !important;">
              <img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAIAAAACACAYAAADDPmHLAAACc0lEQVR4nO3dL0uDURSA8SlaTTJY0CwGscwiVqtfQCx+AZOfwC9hsIjNZDFYBtpMYhCzhsEwCSaDdpGdcHY5rz7Prw7f3cnDhXPf/en1JEmSJEkSxVz1AiLL48lX9Roy3gb9Tv+P56sXoFoGAGcAcAYAZwBwBgBnAHDlM2rrOX/xdT31958rTzNaye+qzwncAeAMAM4A4AwAzgDgDADOAODKzwEi0TlBds7Pis4Jojl/6Wqn6TnI+97d1Od3B4AzADgDgDMAOAOAMwA4A4BbqF5AJHu/fHC/nJqzx1tvwfP3M5cv5w4AZwBwBgBnAHAGAGcAcAYAlz4HWLvYaHo/e/vkOHeBg+QC1npNX99l77Tl5UPuAHAGAGcAcAYAZwBwBgBnAHDhvfZozt+8WZ3dan7xsPsy9fH0OUFj1+dHUx+P3m8QfW4get9/xB0AzgDgDADOAOAMAM4A4AwArvxzAdGc/9dFc370uYWP8WzX85M7AJwBwBkAnAHAGQCcAcAZAFzzc4D/Pudnxe8HaPu5BHcAOAOAMwA4A4AzADgDgDMAuPQ5QPWcf3I7Kn3+Qf+s87+5MI07AJwBwBkAnAHAGQCcAcAZAFx6hm39PYGj3WHLyzfX9XMCdwA4A4AzADgDgDMAOAOAMwC49PsBnvcf2865k2HqnCE7h48nh03POaq5A8AZAJwBwBkAnAHAGQCcAcCV36vOztnV99v/+vrdAeAMAM4A4AwAzgDgDADOAODKzwGi78uPvkev67r++twB4AwAzgDgDADOAOAMAM4A4Jr/XkA0B9NVnxO4A8AZAJwBwBkAnAHAGQCcAUiSJEmSJEF8Az49ZIpT11hRAAAAAElFTkSuQmCC

" style="height: auto">

            </figure>

            <figure style="margin: 5px !important;">
              <img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAIAAAACACAYAAADDPmHLAAACTUlEQVR4nO3dIU5DQRRA0UIQlQgchtBFVKCqYANVX2CaYJAYVoBhCRUg2AMoFKKLKEEikRUksIN54mUy83vvsQ3tb3MzyZsOv5OJJEmSJEmiOGh9AbW9vG/+Mn8/LOZ7/Rkdtr4AtWUAcAYAZwBwBgBnAHAGADf6GTc752fV3id4u/4ovr/L54vU67sCwBkAnAHAGQCcAcAZAJwBwB21vgC6aM7P/n20T+AKAGcAcAYAZwBwBgBnAHAGADf68wCR1v8XkJ3TPQ+gqgwAzgDgDADOAOAMAM4A4KrvA+y2n8U5djo7L17Dardteu4/a3nzXXw8O8dnuQLAGQCcAcAZAJwBwBkAnAHAhTNoNMdnPf68Fh+/O74qPn572nabYD2dFT/D6DzCydNv8flr7xO4AsAZAJwBwBkAnAHAGQCcAcB5f4Ck6LzCEOwTZO8PkOUKAGcAcAYAZwBwBgBnAHAGAJc+DxB9nx+Jvu+P9H4eIMv7A6gqA4AzADgDgDMAOAOAMwC49HmA7ByfFc3hX/er1EbB2cN6r++l6AoAZwBwBgBnAHAGAGcAcAYAF+4DRPfxq33/gOj1s3N+JHr+se8TuALAGQCcAcAZAJwBwBkAnAHAdf97Ab3P4b1fX8QVAM4A4AwAzgDgDADOAOAMAK75jDr2OTrS+/tzBYAzADgDgDMAOAOAMwA4A4BrPmNHv6s3LObNrzGj9/fnCgBnAHAGAGcAcAYAZwBwBgBX/XcDozmYrvU+gSsAnAHAGQCcAcAZAJwBwBmAJEmSJEkSxD/+KYAjxCOPBgAAAABJRU5ErkJggg==

" style="height: auto">

            </figure>

            <figure style="margin: 5px !important;">
              <img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAIAAAACACAYAAADDPmHLAAACTUlEQVR4nO3dMUoDQRhA4VW8hRLRRuyCnWBuYecZQkobSxvLkM7CzpOkD3YhjULQTryCHkCYXxiHfzfvfe0SMgmPgZndSbpOkiRJkiRR7GUPoLXn28PvmtffPHzs9He0nz0A5TIAOAOAMwA4A4AzADgDgBv8Grd2nV9r6PsEzgBwBgBnAHAGAGcAcAYAZwBwB9kD2HV3m7fiPsX92UlxH6H29RFnADgDgDMAOAOAMwA4A4AzALhB38v+i+xzAdE6vrVon8AZAM4A4AwAzgDgDADOAOAMAC59H2DbLVPXya09bo6K130eQKkMAM4A4AwAzgDgDADOAODicwHLWXEd+nI6qxrAV3B9/DovXt9Orqvev7Xzp6vsIRQ5A8AZAJwBwBkAnAHAGQCcAcBV/z5AtE6P1O4j9F10riA6t7D+3+H84gwAZwBwBgBnAHAGAGcAcAYAFz9TXvk8QO0+QTeZF8eYfa5g1E2anq3wXICaMgA4A4AzADgDgDMAOAOAi58HCNbh465ynV/pc3Gc+v7dNPftazkDwBkAnAHAGQCcAcAZAJwBwPX+fwNXi22vf0cwGt/FdJT+W4wlzgBwBgBnAHAGAGcAcAYAZwBwvd8HiGSvs1vvU9Q+9x9xBoAzADgDgDMAOAOAMwA4A4BLv1c99Pvpkb5/PmcAOAOAMwA4A4AzADgDgDMAuPTnAdbvl9lDaKrvn88ZAM4A4AwAzgDgDADOAOAMAK75PkD0v3h00fcT/e9gLWcAOAOAMwA4A4AzADgDgDMASZIkSZIkiB+XMGEfcywICgAAAABJRU5ErkJggg==

" style="height: auto">

            </figure>

            <figure style="margin: 5px !important;">
              <img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAIAAAACACAYAAADDPmHLAAACSUlEQVR4nO3dL04DQRhA8YXgIBgEjgOsx5FwARwKQYLCYQkVVStIQHIBEgQKxwVIcPg9AA7LHw03mE98GWa37/0sbDttXiaZ6XTbdZIkSZIkiWKt9QBqG5c3v5nr++Fypd+j9dYDUFsGAGcAcAYAZwBwBgBnAHCzX+Nm1/lZtfcJHo7fi6/v9Gkv9fzOAHAGAGcAcAYAZwBwBgBnAHAGAGcAcAYAZwBwBgBnAHAGAGcAcButB5AVfR7v9wLKnAHgDADOAOAMAM4A4AwAzgDgwn2Azc++uI7+2R5T6+TW5/ojtcfXep/BGQDOAOAMAM4A4AwAzgDgDAAufR7garFTXCffLXaL1+9396nnf7s9S12fVfs8Qm3OAHAGAGcAcAYAZwBwBgBnAHDhZ9HReYDWpr4PEInuA5gV3UfQGQDOAOAMAM4A4AwAzgDgDAAufR7g4vqj+PfoPED2+rmL1un+XoCqMgA4A4AzADgDgDMAOAOAm/15gOj+BM/fL6nxH20dep9ArS4DgDMAOAOAMwA4A4AzALjwPEC0zq69TxA9f/T9+z65jg8ff+a/J+AMAGcAcAYAZwBwBgBnAHAGADf5NezU1+FTH1/EGQDOAOAMAM4A4AwAzgDgDACu+Rp17uvoyNRfnzMAnAHAGQCcAcAZAJwBwBkAXPo+gZGDcVn+3sBj7RFMW/T+vPZD1X0CZwA4A4AzADgDgDMAOAOAMwC46vsAkfOTr/I/DP8zjlrC19eYMwCcAcAZAJwBwBkAnAHAGYAkSZIkSRLEH9QAawt7giYRAAAAAElFTkSuQmCC

" style="height: auto">

            </figure>

            <figure style="margin: 5px !important;">
              <img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAIAAAACACAYAAADDPmHLAAACBElEQVR4nO3dsW0UQRiA0QUROyEgdewOKMAVUAApEQ04dgN0QAFU4ALcgWNSAhIagA52kEar2fX3Xn6nudWnkf7ZvbttAwAAACrerF7A0V7uv/2def3d09dXfY3erl4AawkgTgBxAogTQJwA4gQQd/kZd3bOn3X1cwI7QJwA4gQQJ4A4AcQJIE4AcQKIE0CcAOIEECeAOAHECSBOAHGXvpf9P3wvYJ8dIE4AcQKIE0CcAOIEECeAuOUz7urn+ldbfc5gB4gTQJwA4gQQJ4A4AcQJIO7d6gWMjObk1ecIs+v7/ePh0PW///S4uz47QJwA4gQQJ4A4AcQJIE4AcYefA4zm4NX3w482PCfY9q/Phy+/dt9/NOeP2AHiBBAngDgBxAkgTgBxAogbzpBH36/mWJ4HYJcA4gQQJ4A4AcQJIE4Aca/6Xvy2bdvNx89T5xh/nr8vvUajcxjPAzBFAHECiBNAnADiBBAngLjLnwMc/b2Do9/f7wOwlADiBBAngDgBxAkgTgBxpz8HOPvvC5x9fSN2gDgBxAkgTgBxAogTQJwA4pbPqFefo0fO/vnsAHECiBNAnADiBBAngDgBxB0+g/58uZ967v327unS5wBn//x2gDgBxAkgTgBxAogTQJwA4qb/N3B2zmXf6PrOnhPYAeIEECeAOAHECSBOAHECAAAAAIj4B4VJXeY6hl28AAAAAElFTkSuQmCC

" style="height: auto">

            </figure>

            <figure style="margin: 5px !important;">
              <img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAIAAAACACAYAAADDPmHLAAAClklEQVR4nO3dMUpcURhHcRNs3MBbQxYwRbYQsEghBJEgpLSZIk2KlLYWLsFChoiFhZAsQkibOuVrLaYJJBsI92/yeblPz/m1w9P75HDhu/Nm3NmRJEmSJEkUL0YvINkc7/9uvX54cdu8h3R9Uv356frRXo5egMYyADgDgDMAOAOAMwA4A4CLM+rn6x+lOfr04FXXOT05+3pUuv7jm8tHWsnfjT4ncAeAMwA4A4AzADgDgDMAOAOA634OkFTPCapzflU6J5ivdpuvr7c3zfs/33vbvP90feIOAGcAcAYAZwBwBgBnAHAGAFd+LzqdE6Q5v3p9spo2pXOMu/mw9PvTHN9bOidwB4AzADgDgDMAOAOAMwA4A4Brv1n9ANU5PZnP94pz9IfiCmq/f/Op/brPA2goA4AzADgDgDMAOAOAMwC48jlAkt7v/3byvXn96bxtzrn1c4Kaad1e32p6117f9uYxl/PP3AHgDADOAOAMAM4A4AwAzgDgup8DJOm5+9FzfpLWN63b9xc/t3D/5T9W9XDuAHAGAGcAcAYAZwBwBgBnAHDlc4Den+9/7tI5yPvO3y/gDgBnAHAGAGcAcAYAZwBwBgA3/HmAJD13nxzvz6U5+uJ2etbnGO4AcAYAZwBwBgBnAHAGAGcAcIs/B0jSc/XVOT79/Or/E0iq3wOYuAPAGQCcAcAZAJwBwBkAnAHALf697tFzeLL09SXuAHAGAGcAcAYAZwBwBgBnAHDDZ9SnPkcnS78/dwA4A4AzADgDgDMAOAOAMwC47p8L+LWamnPw65+9V7Bs6e+zezf7uQD1YwBwBgBnAHAGAGcAcAYAV54x0xxb1XsO7m3pfx93ADgDgDMAOAOAMwA4A4AzAEmSJEmSJIg/+9KVPj1BdCEAAAAASUVORK5CYII=

" style="height: auto">

            </figure>

            <figure style="margin: 5px !important;">
              <img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAIAAAACACAYAAADDPmHLAAACTklEQVR4nO3dIU4DQRhA4aXhAMi9AQSFrgGFIuEEpIIjEFQFRSAbTtA0CA6AxWFQCCQNniA5QcETMr+YTmaW9z67YbuFl0lmdnbpOkmSJEmSRLFV+wJKu3t9/s75+cnB+F//jka1L0B1GQCcAcAZAJwBwBkAnAHADX6OmzvPzzX0dQJHADgDgDMAOAOAMwA4A4AzALjt2hdAd7xzXnQd4/FrkVyncASAMwA4A4AzADgDgDMAOAOAG/w6QHQ/3ucC0hwB4AwAzgDgDADOAOAMAM4A4LLnuBe7b0XvZ9+enJY8fXXr+Sr5N8jdL+B+ACUZAJwBwBkAnAHAGQCcAcCF+wGief71zWxjF/On6UPycOvrBMuzZfL4ZD7OOn80z484AsAZAJwBwBkAnAHAGQCcAcBlPxdwNZ0ljxdfJ2hc7nML90eLzV7QL44AcAYAZwBwBgBnAHAGAGcAcNnrANE8P1onGLpoX38kWico/R5BRwA4A4AzADgDgDMAOAOAMwC44vsBSvt4ea/6+X3VT8/nCABnAHAGAGcAcAYAZwBwBgAXrgPMV3vJ+9Wl3xN42e+XPH22z8NR8vv3T+um/9+AIwCcAcAZAJwBwBkAnAHAGQBc03PUrmt/nt369UUcAeAMAM4A4AwAzgDgDADOAOCynwvIFc2jh671dQJHADgDgDMAOAOAMwA4A4AzALjq96qj9+VH79FrXevfzxEAzgDgDADOAOAMAM4A4AwArvh+gGgeTFd7ncARAM4A4AwAzgDgDADOAOAMQJIkSZIkCeIHluVhq1W+L8EAAAAASUVORK5CYII=

" style="height: auto">

            </figure>

            <figure style="margin: 5px !important;">
              <img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAIAAAACACAYAAADDPmHLAAACTUlEQVR4nO3dMUoDQRSA4UQCdraC3Z4gl/ASgnUOYbBMettUFp5CbD2Aje12goWNnRDQAwjzkOfyZvn/rw2aSfgZmJdNdrGQJEmSJEkUy+oFZA2b43fl84+H1azfw5PqBaiWAcAZAJwBwBkAnAHAGQBc+Rm2+hxfrXqO4A4AZwBwBgBnAHAGAGcAcAYAVz4HyDp/G0rnCO8XY/M93I8PzfXdDNfOAVTHAOAMAM4A4AwAzgDgDABu9nOASHZOEJ3zI9EcYGrRnMEdAM4A4AwAzgDgDADOAOAMAK77OcBuP876ewPLq+fm49E5ferrCdwB4AwAzgDgDADOAOAMAM4A4FbZf/DydNY8p64vP5vn1PDz+vu/r6knd6e31UtocgeAMwA4A4AzADgDgDMAOAOAC+cA0Tk/Ep3zw+vu94tZXw8Qvb5wDvL1r8v5xR0AzgDgDADOAOAMAM4A4AwALn09QOTx9aP5+HrqBXQunIOM085B3AHgDADOAOAMAM4A4AwAzgDgwjlAdF1/9nsBke3NkPr7zXGXOkcfVtvuf0Mhwx0AzgDgDADOAOAMAM4A4AwAbvLrAbKy5/jq5+99juAOAGcAcAYAZwBwBgBnAHAGAJeeA2Q/759a9hxePYfI3g8g4g4AZwBwBgBnAHAGAGcAcAYAV36Gn/vn7XNfvzsAnAHAGQCcAcAZAJwBwBkAXPkcIH0/gc71/vrcAeAMAM4A4AwAzgDgDADOAOAm/32A8L54cNVzAncAOAOAMwA4A4AzADgDgDMASZIkSZIkiB+fm2sdccLO/gAAAABJRU5ErkJggg==

" style="height: auto">

            </figure>

            <figure style="margin: 5px !important;">
              <img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAIAAAACACAYAAADDPmHLAAACFklEQVR4nO3dMW7UQBiA0Q2iiURPjehp0mydnlNwgpwkJ+AUXCINDT1Km/RIlHAApJ1isDze7702seRdfRrpH4+T0wkAAACouNn7Brb2+/3Dn5nrb18fr/o7erP3DbAvAcQJIE4AcQKIE0CcAOIOP+POzvmzjr5PYAWIE0CcAOIEECeAOAHECSDu7egXHp9+bDpnP5w/HXqOHnn+9e3i9/fh3eeLn3/2+hErQJwA4gQQJ4A4AcQJIE4AccN9gNWNnsev/l7AaM6fvX60T2AFiBNAnADiBBAngDgBxAkgbnrGHZ0XGD3v3/tc/9Zeft5f/LnzAOxKAHECiBNAnADiBBAngLjlzwNs/bx/1vD+Pp6W3uewAsQJIE4AcQKIE0CcAOIEELf5PsBoTj/639kbmd3HePm/t/MPK0CcAOIEECeAOAHECSBOAHGb7wNc+5w/a/T9PJ/uNz1PYAWIE0CcAOIEECeAOAHECSBu+fcCRkZz9Jenu6k5+uv5+1XvY1gB4gQQJ4A4AcQJIE4AcQKIO/w+wPC9g/PceYRrf6/BChAngDgBxAkgTgBxAogTQNzyM+zqc/jq9zdiBYgTQJwA4gQQJ4A4AcQJIG73GfXoc/TI6p/PChAngDgBxAkgTgBxAogTQJwA4gQQJ4A4AcQJIE4AcQKIE0Dc7v83sG7v8wJWgDgBxAkgTgBxAogTQJwAAAAAACL+AqJBZ+l+ke/QAAAAAElFTkSuQmCC

" style="height: auto">

            </figure>

            <figure style="margin: 5px !important;">
              <img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAIAAAACACAYAAADDPmHLAAACZklEQVR4nO3cr0qDURiA8SlegDegIruFFaswYUkwmMUghhXXv7Q+i0EMYjYIlg0MFsPKutHgXVj0AoTzKmeH823P86sf6GE8HDjv96fTkSRJkiRJFBu1F5BrsBh91/z/s95kpX/DzdoLUF0GAGcAcAYAZwBwBgBnAHAGAGcAcAYAZwBwBgBnAHAGAGcAcFu1F5CrO3uvvYSk54PL5PMKx/Pbqs8TuAPAGQCcAcAZAJwBwBkAnAHArfQz7X8xHA+y3hu4aWZZv1E0BygtmjO4A8AZAJwBwBkAnAHAGQCcAcBlzwGezj+LnnNf9y9K/vni+tO95PXonF76eQJ3ADgDgDMAOAOAMwA4A4AzALjwvYDcc/746DR5vXl5TF4//LhLXq89JwifF4ieR5gvczX/5w4AZwBwBgBnAHAGAGcAcAYAV/37ALlzgraL5gThewvTpS7nF3cAOAOAMwA4A4AzADgDgDMAuOJzgOgcH80B1l00J+gX/r6AOwCcAcAZAJwBwBkAnAHAGQBc9ecBcu/3R+foxegs6xzdmzys9bcU3QHgDADOAOAMAM4A4AwAzgDgwjnAyf1O8hxc+juBu9tN8np0zs89x6/7HMEdAM4A4AwAzgDgDADOAOAMAK7VZ9ROp/w5P1fb1xdxB4AzADgDgDMAOAOAMwA4A4Cr/l5A7v32tmv7nMAdAM4A4AwAzgDgDADOAOAMAK76HODtq5u8fnXTtPp+enSOvx6OWz3ncAeAMwA4A4AzADgDgDMAOAOAKz4HaPs5uLbo9yk9B3EHgDMAOAOAMwA4A4AzADgDkCRJkiRJgvgBq11qA5VqzgkAAAAASUVORK5CYII=

" style="height: auto">

            </figure>

            <figure style="margin: 5px !important;">
              <img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAIAAAACACAYAAADDPmHLAAACHUlEQVR4nO3dO24UQRRAUYNMZonUIZkTxywGIVgAsRdA7NgLMELshdyJM4ekSM5hB1NBqVXdc8/Je9QzuirpVX/m4gIAAACoeLP6BLb2/PT6b+b4m9urs/6N3q4+AdYSQJwA4gQQJ4A4AcQJIO7wM+7snD/r6PsEVoA4AcQJIE4AcQKIE0CcAOIuZz/g8eevk3P418+fDj0nnzsrQJwA4gQQJ4A4AcQJIE4AcdP7AKuNrsd7LuA0K0CcAOIEECeAOAHECSBOAHG73wdYfd//ue8jWAHiBBAngDgBxAkgTgBxAohbvg8wmrO3vt4/a/b8Rsf/eLk7efyXD/dT+wxWgDgBxAkgTgBxAogTQJwA4oYz5Oj5/1mz7w/Y+z7AyOj8f199n/n44T6BFSBOAHECiBNAnADiBBAngLjh/QCjOd17AufMzvmzrABxAogTQJwA4gQQJ4A4AcQtfy5g1uh6/MOf0/fVj3y7nrvvfmR0vd5zAWxKAHECiBNAnADiBBAngLjDX6ufff5+9eevZgWIE0CcAOIEECeAOAHECSBu9zPs3ufwvZ/fiBUgTgBxAogTQJwA4gQQJ4C45TPq0efokb1/PytAnADiBBAngDgBxAkgTgBxy98P8PHdy+pT2NTev58VIE4AcQKIE0CcAOIEECeAuM33Ad4/Py39X7+9G/0+f29uN71fwAoQJ4A4AcQJIE4AcQKIEwAAAABAxH9E+meymzhDBwAAAABJRU5ErkJggg==

" style="height: auto">

            </figure>

            <figure style="margin: 5px !important;">
              <img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAIAAAACACAYAAADDPmHLAAACTklEQVR4nO3cIUuDQRyA8SmybN0nEAXL4rpFu2BaXDGK2SxGy+KSsA+wYpU3rgwUk3HVKCv6AYT3L5y3u3fP86vqvMnDwf/eeb2eJEmSJEmi2Cu9gNxm6+V3ys+PB8Od/hvtl16AyjIAOAOAMwA4A4AzADgDgDsovYBUk2aWNOenvv50NO70OYE7AJwBwBkAnAHAGQCcAcAZAFznzwEizceq9BKq5g4AZwBwBgBnAHAGAGcAcAYA1+ln2X+R+nmB3M/7b+4XWT/P8HB73rp+dwA4A4AzADgDgDMAOAOAMwC45Bl39brJOsc+fj7lfPnsUs8RonOCaM6PuAPAGQCcAcAZAJwBwBkAnAHAhf8XkHvOj1wfXrV+vfQ5QTTn136/gDsAnAHAGQCcAcAZAJwBwBkAXPH7AfrvZ61f3xw9b2kleaSeE/Re/nU5v7gDwBkAnAHAGQCcAcAZAJwBwBU/B6CLzgly3x/gDgBnAHAGAGcAcAYAZwBwBgBX/Bwg9Xl/NEevl5dJc/RgON/puxTdAeAMAM4A4AwAzgDgDADOAODCc4DTk37rHJz7/oDo90dzfuocn/v1S3MHgDMAOAOAMwA4A4AzADgDgKt+hq19Dq99fRF3ADgDgDMAOAOAMwA4A4AzALjiM2rX5+hI7e/PHQDOAOAMAM4A4AwAzgDgDACu+P0Ad18XwXfMt7KOXGp/f+4AcAYAZwBwBgBnAHAGAGcAcNmfRb9NmqT7A46no05/HqD29+8OAGcAcAYAZwBwBgBnAHAGIEmSJEmSBPEDDbRo9jRWqscAAAAASUVORK5CYII=

" style="height: auto">

            </figure>

            <figure style="margin: 5px !important;">
              <img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAIAAAACACAYAAADDPmHLAAACgUlEQVR4nO3dPUoDURRA4fizgXSCIFjYBleghY2JG3ABKcVGxFJsBBEbscwCLGw1opWuQNJauAJxBf4sQHm3uI5v4jlfO0ychMOD+yZOOh1JkiRJkkQxU/sCIudv48/S8d1uv/geovMj2dePzq9ttvYFqC4DgDMAOAOAMwA4A4AzALjqM2p2jh72zlNzftZosjvV+wSuAHAGAGcAcAYAZwBwBgBnAHDV9wEi0Rw9WX/+q0v5Ue9hpXg8mvOPrteK7+9w67HR810B4AwAzgDgDADOAOAMAM4A4OZrX0Ake788+32B6H5/p5t59Vg052e5AsAZAJwBwBkAnAHAGQCcAcCFM/by3mZxDn05uy2+RnT+xv0guoR/LdpnyN7vj7gCwBkAnAHAGQCcAcAZAJwBwKW/D7C0uJC6X333elw8Pre9Wjxeex8hmuNrP78g4goAZwBwBgBnAHAGAGcAcAYAl94HiOb0ps9vu/w+wdVvXs43rgBwBgBnAHAGAGcAcAYAZwBw6X2A98un4vFozs+eP+3C/wvo+HwANcgA4AwAzgDgDADOAOAMAG7qvw9welK34VG/6p9PcwWAMwA4A4AzADgDgDMAOAOAS/9uYPQcwKzoOYRv44uq/3/f7e+0/rcXS1wB4AwAzgDgDADOAOAMAM4A4Fo/w0Zzfu05vO3XF3EFgDMAOAOAMwA4A4AzADgDgKs+o077HB1p+/tzBYAzADgDgDMAOAOAMwA4A4BLPx8gcjPsFefg/YOPpi+hquj9RZ/PYDRpdJ/AFQDOAOAMAM4A4AwAzgDgDAAuPWNGc2xW03Nw09r++bgCwBkAnAHAGQCcAcAZAJwBSJIkSZIkQXwBx9OCC2VmA7wAAAAASUVORK5CYII=

" style="height: auto">

            </figure>

            <figure style="margin: 5px !important;">
              <img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAIAAAACACAYAAADDPmHLAAACF0lEQVR4nO3dMU4VURSA4YexsLAyFtZWLoGEmrgACtZg6QbcgutgCYbaPVhRUVgQK3rYwdzEm8nMm//7+oHh5c9JzmUGTicAAACg4mLrG1jb8+3vl5nr399dHfozerP1DbAtAcQJIE4AcQKIE0CcAOLOfsed3fNnnfs5gQkQJ4A4AcQJIE4AcQKIE0Dc29kv8PTv6+Ie/vHDr8U9efZ65pgAcQKIE0CcAOIEECeAOAHEDXfs0Z6+ttlzAO8FLDMB4gQQJ4A4AcQJIE4AcQKIm95x134e4N23H/9zW7vxeHmz6ff/8v3v4udvAsQJIE4AcQKIE0CcAOIEEDf9XsCs0Z4/+n383v8+wPNp+f5G1//5+Wnx+tGeP2ICxAkgTgBxAogTQJwA4gQQt/o5wGhPP/pz97PnGI+ndZ8nMAHiBBAngDgBxAkgTgBxAohb/Rzg6Hv+rOHzAJfLzwPMMgHiBBAngDgBxAkgTgBxAojb/L2AWaM9+vruYWqPvr/9fOhzDBMgTgBxAogTQJwA4gQQJ4C4sz8HGL53MLnHH/29BhMgTgBxAogTQJwA4gQQJ4C43e+we9/D935/IyZAnADiBBAngDgBxAkgTgBxm++o575Hj+z95zMB4gQQJ4A4AcQJIE4AcQKIE0CcAOIEECeAOAHECSBOAHECiNv8/wbWbf28gAkQJ4A4AcQJIE4AcQKIEwAAAABAxCtuWmJHfuph2wAAAABJRU5ErkJggg==

" style="height: auto">

            </figure>

        </div>

</div>

</div>

</div>
</div>

</div>
