From: "Arnaldo Carvalho de Melo" <arnaldo.melo@gmail.com>
Date: Tue, 28 Nov 2006 20:17:39 +0000
Subject: Re: [PATCH] [DCCP]: Remove allocation of sysctl numbers
Message-Id: <39e6f6c70611281217t6d0880e9oed00a39d37c9631a@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200611281259.13546@strip-the-willow>
In-Reply-To: <200611281259.13546@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 11/28/06, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [DCCP]: Remove allocation of sysctl numbers
>
> This is in response to a request sent earlier by Eric W. Biederman
> and replaces all sysctl numbers for net.dccp.default with CTL_UNNUMBERED.
>
> It has been tested to compile and to work.
>
> Signed-off-by: Gerrit Renker  <gerrit@erg.abdn.ac.uk>
> ------------------------------------------------------------------------------

Thanks, applied, just removed the CTL_UNNUMBERED lines, not needed as
discussed with Eric.

- Arnaldo
