From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 13 Apr 2007 08:20:20 +0000
Subject: Re: [PATCH 24/29] Macro for moving average
Message-Id: <200704130920.20921@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <20070412211727.GY21292@ghostprotocols.net>
In-Reply-To: <20070412211727.GY21292@ghostprotocols.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Thanks a lot for the review & improving it. There is at least one more use of this function,
and it is now much better to read. Glad about it.

|  The moving average computation occurs so frequently in the CCID 3 code that
|  it merits a macro of its own.
|  
|  Committer note: changed the patch to have it as an inline that returns the new
|                  value, keeping the logic.
|  
