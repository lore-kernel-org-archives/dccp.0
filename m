From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Tue, 25 Sep 2007 23:00:45 +0000
Subject: Re: [PATCH 5/8]: Allow to parse options on Request Sockets
Message-Id: <5640c7e00709251600q7749d2fbq5a8053b294214ae4@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200709251530.41488@strip-the-willow>
In-Reply-To: <200709251530.41488@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 9/26/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [DCCP]: Allow to parse options on Request Sockets
>
> The option parsing code currently only parses on full sk's. This causes a problem for
> options sent during the initial handshake (in particular timestamps and feature-negotiation
> options). Therefore, this patch extends the option parsing code with an additional argument
> for request_socks: if it is non-NULL, options are parsed on the request socket, otherwise
> the normal path (parsing on the sk) is used.
>
> Subsequent patches, which implement feature negotiation during connection setup, make use
> of this facility.
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
-- 
Web1: http://wand.net.nz/~iam4/
Web2: http://www.jandi.co.nz
Blog: http://iansblog.jandi.co.nz
