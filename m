From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Wed, 24 Oct 2007 16:10:08 +0000
Subject: Re: [Announce][PATCH v2 1/1]: Patch dropped / [DCCP]:
Message-Id: <20071024161008.GB21383@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
References: <200710241626.44834@strip-the-willow>
In-Reply-To: <200710241626.44834@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Em Wed, Oct 24, 2007 at 04:26:44PM +0100, Gerrit Renker escreveu:
> After discussion with Arnaldo, I have decided to remove the following patch from the test tree
> 
> ------------------------------------------------------------------------------------------
>  [DCCP]: Collect all scattered sysctl variables into sysctl.c
> 
> This
>  1. organizes the sysctl variables which are scattered over many DCCP source
>     files into sysctl.c - so that they can easier be found;
>  2. wraps the compilation of the CONFIG_SYSCTL part into a conditional define
>     - if not enabled, then only the variables will be `compiled';
>  3. shortens the definitions of init/exit dummy functions in the header file.
> ------------------------------------------------------------------------------------------
> 
> As a result, several other patches needed re-adjustment. This involved mostly small changes;
> the biggest is the patch reproduced below (please let me know if not ok with this, the patch
> has only been re-adjusted, but its nature has not changed).
> 
> Compile tested the test tree on two different architectures (i386/sparc64).

Looks ok.

- Arnaldo
