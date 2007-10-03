From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Wed, 03 Oct 2007 20:50:16 +0000
Subject: Re: [PATCH 7/14]: No more CCID control blocks in LISTEN state
Message-Id: <5640c7e00710031350u3caf22fgcc2c9b6f25f527a9@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200710031502.43141@strip-the-willow>
In-Reply-To: <200710031502.43141@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 10/4/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [CCID3]: No more CCID control blocks in LISTEN state
>
> The CCIDs are activated as last of the features, at the end of the handshake, were
> the LISTEN state of the master socket is inherited into the server state of the child
> socket. Thus, the only states visible to CCIDs now are OPEN/PARTOPEN, and the closing
> states.
> This allows to remove tests which were previously necessary to protect against referencing
> a socket in the listening state (in CCID3), but which now have become redundant.
>
> Thanks to Ian McDonald for discussion on this.
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
