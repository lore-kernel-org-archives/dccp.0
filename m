From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 03 Nov 2007 14:35:09 +0000
Subject: Re: [RFC]: Removal of spinlocks/rw_locks in ccid3.c / packet_history.c:
Message-Id: <200711031435.09336@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200711031350.20405@strip-the-willow>
In-Reply-To: <200711031350.20405@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Thank you for the clarification - it is good when this code goes (since it propagated to ccid4,too);
I will take them out. I would like to re-submit a bisectable and repackaged set of the old CCID3 patches,
comments and suggestions are welcome (aiming at fewer patches, since most of the patches just navigate
around and are at micro-granule level).

Gerrit
