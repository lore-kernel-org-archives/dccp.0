From: "Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
Date: Fri, 27 Jul 2007 16:49:31 +0000
Subject: Re: [PATCH 4/5]: Always support Ack Vectors
Message-Id: <39e6f6c70707270949i7e2214adj61ec5916b6e41a75@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200707261356.49095@strip-the-willow>
In-Reply-To: <200707261356.49095@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 7/27/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> Quoting Ian McDonald:
> |  > [DCCP]: Always support Ack Vectors
> |  >
> |  > This removes CONFIG_IP_DCCP_ACKVEC for reasons of inter-operability.
> |  >
> |  > In RFC 4340 requires CCID2 as a kind of default (section 10):
> |  > "A DCCP implementation intended for general use, such as an implementation
> |  > in a general-purpose operating system kernel, SHOULD implement at least CCID 2.2
> |  >
> |  > RFC 4341, section 4 says that the use of "Ack Vector is MANDATORY on CCID 2 half-connections".
> |  > (This was so far ensured via Kconfig option). New connections start with CCID 2 for both
> |  > endpoints [RFC 4340, sec. 10]
> |  >
> |  > Taken together this indicates that Ack Vectors should not be disabled in the build process.
> |  >
> |  > Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> |
> |  NAK.
> |
> |  Only CCID2 needs Ack vectors, CCID3 doesn't.
> |
> This is not so much about which CCID needs but about a minimally-compliant implementation in
> terms of compile-time options. The point that I wanted to make is the following:
>
>  DCCP mandates a `minimum implementation' = CCID2
>      => CCID2 mandates Ack Vectors
>      => Ack Vectors are not optional but mandatory

Its useful for debugging, reducing the complexity by disabling this feature.

It is possible to build a kernel without CCID2, and thus without Ack
vectors, so I'd prefer to leave it as is.

The major Linux OS vendors would always enable CCID2 and its
requirement, ACK vectors, to be standards compliant, of course.

- Arnaldo
