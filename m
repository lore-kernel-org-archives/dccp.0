From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 21 Aug 2007 07:11:12 +0000
Subject: Re: [PATCH 0/15] dccp ktime_t conversion and a fix
Message-Id: <200708210811.12937@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <20070819234821.GD24792@ghostprotocols.net>
In-Reply-To: <20070819234821.GD24792@ghostprotocols.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Thanks a lot for all the good work - I have updated the test tree with regard to
this changeset, summary of changes follows separately.

There are a few bug fix patches, the most prominent is the Sync Flood one (I have
put this at the top of the tree, so that it does not depend on the other patches in 
the tree). Would you like me to resend this or what are future plans? 

Another question I wanted to raise is whether people would be ok to have some of the 
patches compacted in the test tree - there are so many patches that tracking even small 
changes can be quite time consuming.
