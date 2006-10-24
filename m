From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 24 Oct 2006 08:12:17 +0000
Subject: Re: 2.6.19-rcX vs 2.6.20
Message-Id: <200610240912.18076@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200610240848.47708@strip-the-willow>
In-Reply-To: <200610240848.47708@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi Arnaldo,

|  I guess I should just create a net-2.6.20 git tree to fix this
|  situation, but I guess you guys could also maintain git trees
|  somewhere, so that I could pull from you, what do you think?
If that would make the situation better, I'll do that. We've got
web servers and the like here. So ... that would be like
	* patches sent to Arnaldo for checking
	* Arnaldo merges into his 2.6.20 tree
	* Gerrit (or Ian or Andrea) pulls Arnaldos changes
	* whoever pulled last, keeps it consistent with netdev tree
	* next time patches come in for revision, Arnaldo can pull 
          from the up-to-date tree
	* or ... ?

That would be great - these patches are just in the way to get other
work done.

Gerrit
	
