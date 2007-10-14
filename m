From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Sun, 14 Oct 2007 00:22:31 +0000
Subject: Re: [PATCH 4/5]: Leave headroom for options when calculating the MPS
Message-Id: <5640c7e00710131722v255a71caha51082c20b6892a4@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200710121051.57905@strip-the-willow>
In-Reply-To: <200710121051.57905@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 10/12/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [DCCP]: Leave headroom for options when calculating the MPS
>
> The Maximum Packet Size (MPS) is of interest for applications which want
> to transfer data, so it is only relevant to the data transfer phase of a
> connection (unless one wants to send data on the DCCP-Request, but that is
> not considered here).
>
> The strategy chosen to deal with this requirement is to leave room for only
> such options that may appear on data packets.
>
> This excludes in particular variable-length options such as Ack Vector:
> as detailed in section 11.2 of RFC 4340, such options can use a separate
> Ack if a current DataAck packet does not have sufficient room left.
>
> There are currently no CCID-specific header options which may appear on data
> packets, hence it is not necessary to define a corresponding CCID field.
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
