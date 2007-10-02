From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 02 Oct 2007 10:15:01 +0000
Subject: Re: [PATCH 2/3]: One more exemption from full sequence number checks
Message-Id: <200710021115.01277@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200709291742.54639@strip-the-willow>
In-Reply-To: <200709291742.54639@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

|  Does this affect DCCP on IP v6? If it does, it should be fixed also.
|  If it doesn't then can you add that to the changelog to stop others
|  asking also.
This patch is for IPv4 only - I have checked, dccp_v6_err uses a different
mechanism, so the problem fixed by this patch does not seem to appear in IPv6
as well.
Must however admit that I haven't tested the IPv6 error reporting exhaustively
(but will soon be doing more IPv6 apps), it would be good if others could test as well.
