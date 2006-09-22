From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 22 Sep 2006 10:46:37 +0000
Subject: Re: [PATCH 7/7] [DCCP]: Remove socket option
Message-Id: <200609221146.37827@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200609221433.48612.ian.mcdonald@jandi.co.nz>
In-Reply-To: <200609221433.48612.ian.mcdonald@jandi.co.nz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

|  This removes DCCP_SOCKOPT_PACKET_SIZE for two reasons:
|  * the current code doesn't work
|  * tx and rx should be different (introduced in former patch)

Agree that DCCP_SOCKOPT_PACKET_SIZE is redundant, patch looks good and
has been tested.

Acked-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
|  Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
