From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 11 Mar 2008 15:08:48 +0000
Subject: [DCCP-Apps] [Announce]: DCCP support for three audio clients
Message-Id: <20080311150848.GA19614@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

The following URL gives access to several audio streamers patched for DCCP:
http://www.erg.abdn.ac.uk/users/gerrit/dccp/apps/#audio_clients

These can be used as clients for servers such as paraslash or gstreamer, and
work for IPv4 and IPv6.

There are two variants of mpg123 and one variant of vorbis-tools/ogg123 to
support a pseudo-URI of the type `dccp://' with the following syntax:

	dccp://hostname		# DNS hostname and default port 8000
	dccp://hostname:9011	# same but on non-default port
	dccp://10.0.0.1		# native IPv4 address with default port 8000
	dccp://10.0.0.2:8001	# same, but with non-default port
	dccp://[beef::4]	# IPv6 address as per RFC 3986 with default port
	dccp://[::]:1234	# connecting to IPv6 localhost on port 1234


Individual notes:
-----------------
(1) mpg123
 * the mpg123-0.60 patch uses buffered stdio (fread()) to turn the stream of datagrams into
   the bytestream expected by the decoder;
 * the mpg123-1.2.0 patch achieves the same purpose by fork()ing a separate process acting as
   a producer filling a pipe(2), which presents the bytestream abstraction to the main process;

(2) ogg123
    This requires several other packages to build: (pthreads, libcurl(-dev), libao(-dev)).
    The patch performs the transformation from datagram stream into bytestream using a pthread,
    which fills a circular buffer (also used by the http subsystem) - similar to buffered stdio.

(3) dccp_pipe
    The dccp_pipe is a simple sink which reproduces its input - in combination with a named
    pipe (mkfifo), a pipe (`|') to stdout etc. it can be used as input source for such audio 
    (and possibly video) decoders that are able to read from stdin;
    This application also resolves hostnames as well as IPv4/v6 addresses and can be used as
    a simple "stream-ripper" as in the following example (uses also port 8000 as default):

   	dccp_pipe --connect 10.0.0.1 --stdout | tee stream_rip.mp3 | mpg123 -vb64 -
