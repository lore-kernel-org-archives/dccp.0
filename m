From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Thu, 28 Aug 2008 21:00:31 +0000
Subject: Re: [PATCH 08/37] dccp: Query supported CCIDs
Message-Id: <20080828210031.GO9193@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
References: <1219945512-7723-9-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <1219945512-7723-9-git-send-email-gerrit@erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Em Thu, Aug 28, 2008 at 07:44:43PM +0200, Gerrit Renker escreveu:
> This provides a data structure to record which CCIDs are locally supported
> and three accessor functions:
>  - a test function for internal use which is used to validate CCID requests
>    made by the user;
>  - a copy function so that the list can be used for feature-negotiation;
>  - documented getsockopt() support so that the user can query capabilities.
> 
> The data structure is a table which is filled in at compile-time with the
> list of available CCIDs (which in turn depends on the Kconfig choices).
> 
> Using the copy function for cloning the list of supported CCIDs is useful for
> feature negotiation, since the negotiation is now with the full list of available
> CCIDs (e.g. {2, 3}) instead of the default value {2}. This means negotiation
> will not fail if the peer requests to use CCID3 instead of CCID2.

But this limits us to the CCIDs at kernel build time, what if I want to
test CCID4? I guess we could have something like a bitmap and check if
the bit for that CCID is set, and it would be set at ccid_register time.

Perhaps using include/linux/bitmap.h :-)

- Arnaldo
