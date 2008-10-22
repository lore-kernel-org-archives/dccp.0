From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 22 Oct 2008 15:55:32 +0000
Subject: Re: Protocol not attached
Message-Id: <20081022155532.GA6640@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <5bc4c4570809291133k3f5841b1qde962bd3b4882439@mail.gmail.com>
In-Reply-To: <5bc4c4570809291133k3f5841b1qde962bd3b4882439@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| > > Using the Linus git iperf run successfully. Then, does we have
| > > something broken in Gerrit git three?
| > >
| > > Leandro.
| > >
| > 
| > 
| > I meant, (...) "Gerrit git tree"
| 
| I looks like, you could then try to help Gerrit by doing a git bisection
| on his tree, starting from where he branched, see:
| 
| http://www.arthurgeek.net/git-bisect/
| 
| for a git bisect tutorial, even in portuguese :-)
| 
I will have a more detailed look at home. But between the stable tree
and the linus sources there is another intermediate step that one could
try, which is testing if the netdev-2.6 has any problems:

 1) if you are pulling the entire dccp_exp tree, you could test this
    by simply checking out 'master';
 2) otherwise, the netdev-2.6 tree can be pulled via
    git pull git://eden-feed.erg.abdn.ac.uk/dccp_exp  +master:my_local_subtree

Many thanks for this testing, I will also look through.

Gerrit
