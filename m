From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Wed, 03 Oct 2007 18:49:08 +0000
Subject: Re: [PATCH 3/14]: Integration of dynamic feature activation - part 2 (server side)
Message-Id: <5640c7e00710031149m375ff95w4adc22ca5def140a@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200710031502.34134@strip-the-willow>
In-Reply-To: <200710031502.34134@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 10/4/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [DCCP]: Integration of dynamic feature activation - part 2 (server side)
>
> This patch integrates the activation of features at the end of negotiation into the
> server-side code.
>
> Note: In dccp_create_openreq_child the request_sock argument is no longer constant,
>       since dccp_activate_values() uses the feature-negotiation list on dreq to
>       sort out the initialisation values for the different features of the child
>       socket; and purges this queue after usei (the `req' argument to openreq_child
>       was kept constant, however).
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
