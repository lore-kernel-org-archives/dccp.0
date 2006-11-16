From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 16 Nov 2006 14:07:16 +0000
Subject: Re: [PATCH 5/7] [DCCP]: Introduce two new socket options
Message-Id: <200611161407.16950@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200609221430.14555.ian.mcdonald@jandi.co.nz>
In-Reply-To: <200609221430.14555.ian.mcdonald@jandi.co.nz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Quoting Arnaldo Carvalho de Melo:
|  On 9/22/06, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
|  > Quoting Eddie Kohler:
|  > |  > Why burden the application programmer to handcode an estimation of the average each
|  > |  > time? I can not see a justification for this, certainly not for CCIDs which
|  > |  > are intended to be used with (on average) fixed packet sizes.
|  > |  >
|  > |  > I think that a priority is to keep the user programming interface as simple as
|  > |  > possible -- like UDP's interface, as stated in RFC 4340.
|  > |
|  > |  But if DCCP_SOCKOPT_TX_PACKET_SIZE defaults to the MSS, which the drafts
|  > |  explicitly allow, then there's no burden on the application programmer.
|  > This is a good input and  should be related to patch 6/7 in which the default setting is
|  > the standard size packet of 256 bytes; so maybe we should use MSS (or an estimate of it) there.
|  
|  Hi Folks, could Ian or Gerrit respin these patches to reflect what was
|  discussed here? Perhaps we can get this merged in 2.6.20 if we get
|  this done and tested before the merge window closes.
I am working on this, hope to have patch ready by end of next week. 

Gerrit
