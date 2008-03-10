From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 10 Mar 2008 14:10:42 +0000
Subject: Re: Reporting possible bug in DCCP Feature negotiation
Message-Id: <20080310141042.GA7984@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <5bc4c4570803061215s36fac06ctc2015cc2d079ea9@mail.gmail.com>
In-Reply-To: <5bc4c4570803061215s36fac06ctc2015cc2d079ea9@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| negotiate its features. I will try to reproduce this, so far parallel
| connections of up to 4 streams worked without glitches.
| 
Tested up to 56 connections in parallel. At values > 50 this results
frequently in a Reset with Reset Code "Too Busy", which is translated
into the (appropriate) error message "Too many users".

Could not trigger specified bug.
