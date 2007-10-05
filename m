From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Fri, 05 Oct 2007 06:27:43 +0000
Subject: Re: [PATCH 1/5]: Exploit the `Ack Pending' flag
Message-Id: <5640c7e00710042327n3f917196taef87fc0e5aeac9@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200710041501.49058@strip-the-willow>
In-Reply-To: <200710041501.49058@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 10/5/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [DCCP]: Exploit the `Ack Pending' flag
>
> This provides a wrapper around the function which sets the `Ack Pending' flag
> on inet connection sockets. This is very useful for some DCCP cases, such as
> the out-of-band feature negotiation of NN options for an established connection
> (next patches).
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
