From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 09 Aug 2007 13:56:42 +0000
Subject: [PATCH 0/3]: Shutdown support and CCID2-default
Message-Id: <200708091456.42227@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

I will be away next week and so am sending the last patches today,
so that people can comment (I would like to put these into the test tree tomorrow).

Patch #1: Exploits shutdown information (when set) to reduce the per-packet processing
          costs. This is follow-up stuff from the work on closing states, I have put
          documentation on http://www.erg.abdn.ac.uk/users/gerrit/dccp/notes/shutdown/
          and also tested this with VLC (which uses shutdown). The point is that if
          no traffic is sent, one may as well close that half connection and avoid the
          extra processing costs. Will post VLC patch later.

Patch #2: Make CCID2 default - following discussions with Ian.
Patch #3: Documentation from #2, separated out and updated.
