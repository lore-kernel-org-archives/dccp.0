From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Fri, 05 Oct 2007 07:04:15 +0000
Subject: Re: [PATCH 5/5]: Use feature-negotiation to report Ack Ratio changes
Message-Id: <5640c7e00710050004x3db861dep5f08642b96b4bee3@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200710041502.22109@strip-the-willow>
In-Reply-To: <200710041502.22109@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 10/5/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [CCID2]: Use feature-negotiation to report Ack Ratio changes
>
> This uses the new feature-negotiation framework to signal Ack Ratio changes,
> as required by RFC 4341, sec. 6.1.2.
>
> This raises some problems for CCID2 since it can at the moment not cope grace-
> fully with Ack Ratio of e.g. 2. A FIXME has thus been added which reverts to
> the previous policy of bypassing the Ack Ratio sysctl.
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
