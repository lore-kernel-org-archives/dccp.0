From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 02 Jun 2008 08:10:45 +0000
Subject: Re: test tree?
Message-Id: <20080602081045.GA8528@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <200806010001.20158.tomasz@grobelny.oswiecenia.net>
In-Reply-To: <200806010001.20158.tomasz@grobelny.oswiecenia.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| > Has anything changed about dccp test tree git repository? I cannot fetch it:
| > $ git fetch origin
| > fatal: read error (Connection reset by peer)
| > --
Can you please try again - it seems that there was a firewall problem over the weekend.
I can see everything locally, when I connect from the outside via shell-account, I get

gerrit@byte-hosting ~$ /git-ls-remote git://eden-feed.erg.abdn.ac.uk/dccp_exp dccp ccid4
c64a1f7e8f21dd986c421eeb5480b9bfa0504f34        refs/heads/ccid4
1ab1b53e0762af74198a946de01b8180e4fa8e73        refs/heads/dccp

So it should be ok now!
