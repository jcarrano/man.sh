==================================
The fancy CGI viewer for man pages
==================================

----------------------------------------------------------
Including, free of charge, a shell-script based web server
----------------------------------------------------------

Why?
====

For the glory of `sed <https://www.gnu.org/software/sed/>`_ of course!

.. DANGER::
	This software comes with no warranty, and is not meant to be used in
	hospitals, power facilities, businesses, homes, or any computer, not
	even your computer. The security of these scripts is the worst in the
	universe. Do not run these scripts unless you want to be pwned like
	never before in your life.

What is this?
=============

Basically some stuff I did back in 2011 just for fun, but never published.
See an example of the output `here <http://htmlpreview.github.io/?https://github.com/jcarrano/man.sh/blob/master/man.html>`_

man.sh
------

This is thin CGI wrapper around man2html, so that it is more usable and looks
prettier.

It makes used of the stylesheet included in style/simple.css

Also check out the example htaccess, though I would strongly suggest you don't
use it

Call it without arguments to use as CGI script. Use ``man.sh [section] page``
to render a single page to HTML.

server.sh
---------

Let's face it: configuring and running a web server is too much of a burden.
After all, what is a HTTP server but a text processor. server.sh is a web server
written in shell, using netcat. It can run the man.sh cgi script (but probably
not any other script, as it does not set env variables!).

Start it with ``server.sh serve``.

Sometimes it does not respond to Control-C so it's necessary to kill it. It
should be possible to solve it by some use of subshells, but...

License (like it mattered)
==========================

This stuff was written by Juan I Carrano <juan@carrano.com.ar>

::

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are
  met:

  * Redistributions of source code must retain the above copyright
    notice, this list of conditions and the following disclaimer.
  * Redistributions in binary form must reproduce the above
    copyright notice, this list of conditions and the following disclaimer
    in the documentation and/or other materials provided with the
    distribution.
  * Neither the name of the  nor the names of its
    contributors may be used to endorse or promote products derived from
    this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
  A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
  OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
  LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
  THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
