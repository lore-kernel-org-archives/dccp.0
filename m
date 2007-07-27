From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Fri, 27 Jul 2007 04:50:56 +0000
Subject: Re: [PATCH 1/5]: Collect all scattered sysctl variables into sysctl.c
Message-Id: <5640c7e00707262150q7c5f0a8xe56c3563bcc85da4@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200707261356.18246@strip-the-willow>
In-Reply-To: <200707261356.18246@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 7/27/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [DCCP]: Collect all scattered sysctl variables into sysctl.c
>
> This
>  1. organizes the sysctl variables which are scattered over many DCCP source
>     files into sysctl.c - so that they can easier be found;
>  2. wraps the compilation of the CONFIG_SYSCTL part into a conditional define
>     - if not enabled, then only the variables will be `compiled';
>  3. shortens the definitions of init/exit dummy functions in the header file.
>
> Hence mainly a tidy-up action. Code was found to compile and work
> cleanly with various Kconfig configurations for SYSCTL.
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
-- 
Web1: http://wand.net.nz/~iam4/
Web2: http://www.jandi.co.nz
Blog: http://iansblog.jandi.co.nz
