From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Mon, 01 Oct 2007 03:28:49 +0000
Subject: Re: [PATCH 9/11]: Provide documentation for undocumented sockopt struct
Message-Id: <5640c7e00709302028j43a58878vfc45c3e0180399de@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 9/28/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [DCCP]: Provide documentation for undocumented sockopt struct
>
> Also changed the type of the value pointer to void*, to enable
> passing NN values (up to 48 bit) onto the socket.
>
> FIXME: I think that this struct might be useful for testing, but it
>        would be better to phase it out and replace it by proper socket
>        options (setsockopt code for the CCID follows in a later patch).
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>

-- 
Web1: http://wand.net.nz/~iam4/
Web2: http://www.jandi.co.nz
Blog: http://iansblog.jandi.co.nz
