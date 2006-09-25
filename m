From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 25 Sep 2006 08:33:08 +0000
Subject: Re: [PATCH 2.6.19] net/dccp: set safe upper bound for option length
Message-Id: <200609250933.08447@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <39e6f6c70609220750i681a28c4lf912c7ccb393cd72@mail.gmail.com>
In-Reply-To: <39e6f6c70609220750i681a28c4lf912c7ccb393cd72@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi Arnaldo

|  With this change DCCP_MAX_PACKET_HDR is not used anywhere, I'm
|  rewriting it so that we use it to calculate MAX_DCCP_HEADER, 
That is great, thank you for updating.

Gerrit
