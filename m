From: <vladimir.moltchanov@nokia.com>
Date: Thu, 22 Nov 2007 15:53:32 +0000
Subject: RE: [RFC]: Withdrawal of passive-close patches
Message-Id: <8B1D53AEF7B03449A6D3771B3B7F850F046FDB17@esebe103.NOE.Nokia.com>
List-Id: <dccp.vger.kernel.org>
References: <20071122153843.GA13762@gerrit.erg.abdn.ac.uk>
In-Reply-To: <20071122153843.GA13762@gerrit.erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

 

>-----Original Message-----

...snip...

>If you or anyone on the list can create a condition which will 
>lead to "application received data but didn't have a chance to 
>read it", I'd like to hear about it.

... snip ...

>---------------------------


If application first queries the message size in the receive buffer  and
only then issues a read command may have trouble if socket discards the
data in the meantime. Scenario is possible if one is using select()
call.


B.R.
Vladimir.
