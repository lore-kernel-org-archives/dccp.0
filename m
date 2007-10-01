From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Mon, 01 Oct 2007 23:06:40 +0000
Subject: Re: [PATCH 7/11]: Integrate feature-negotiation insertion code
Message-Id: <5640c7e00710011606y49490ddbtd2d1219bc5c659a3@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200710011518.26652@strip-the-willow>
In-Reply-To: <200710011518.26652@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 10/2/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [DCCP]: Integrate feature-negotiation insertion code
>
> The patch implements insertion of feature negotiation at the server (listening and
> request socket) and the client (connecting socket).
>
> In dccp_insert_options(), several statements have been grouped together now to achieve
> (I hope) better efficiency by reducing the number of tests each packet has to go through:
>  - Ack Vectors are, as before, sent if the packet is neither a Data or a Request packet;
>  - a previous issue is corrected - feature negotiation options are allowed on DataAck
>    packets (5.8).
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
