From: "=?ISO-2022-JP?B?GyRCJUQbKEIgTGVhbmRybyBTYWxlcw==?="
Date: Wed, 26 Sep 2007 23:51:12 +0000
Subject: Re: Towards the ccid-3 and ccid-4 integration
Message-Id: <5bc4c4570709261651t29d2c7f2u98c98fb068af0c97@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <5bc4c4570709241115u1254baa9j7033d1bdc9dc079@mail.gmail.com>
In-Reply-To: <5bc4c4570709241115u1254baa9j7033d1bdc9dc079@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

2007/9/25, Gerrit Renker <gerrit@erg.abdn.ac.uk>:
> Sorry for the delay there were local bank holidays here.
>
> |  - Rewrite all the patches (from me and Tommi) and resubmit to Gerrit
> |  as a unique patchset, as suggested by Ian. Besides, ask Gerrit to
> |  overwrite the current ccid4 branch;
> |  - Identify and provide common code between ccid-4 and ccid-3.
> |   1 - minor functions from ccid-3.c to ccid-3.h and include it (.h) in
> |  the ccid-4.c, as suggested by Ian and Arnaldo
> |   2 - for more complex functions, write a dccp_ccid3_lib.ko, as
> |  suggested by arnaldo
> The ideas sound good, and I think it is a good idea to factor out what is
> not needed - just unclear which patch set to use, the latest so far is from
> Thursday?
> -
> To unsubscribe from this list: send the line "unsubscribe dccp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

Hi,
  Gerrit, the latest so far is from Friday, the mine, which it was
similar to the Tommi patch, so then I just patches the differences
between the mine and the tommi's patchset. But I'm put all the patches
together (the mine and tommi as one patchset and I will ask you to
overwrite the current ccid4 branch. Besides, I'm going through the
ideas of dccp_ccid3_lib.ko.

Leandro.
