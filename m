From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Fri, 27 Jul 2007 04:58:42 +0000
Subject: Re: [PATCH 4/5]: Always support Ack Vectors
Message-Id: <5640c7e00707262158h1fd5740ar520863139110f3b7@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200707261356.49095@strip-the-willow>
In-Reply-To: <200707261356.49095@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 7/27/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [DCCP]: Always support Ack Vectors
>
> This removes CONFIG_IP_DCCP_ACKVEC for reasons of inter-operability.
>
> In RFC 4340 requires CCID2 as a kind of default (section 10):
>  "A DCCP implementation intended for general use, such as an implementation
>   in a general-purpose operating system kernel, SHOULD implement at least CCID 2.2
>
> RFC 4341, section 4 says that the use of "Ack Vector is MANDATORY on CCID 2 half-connections".
> (This was so far ensured via Kconfig option). New connections start with CCID 2 for both
> endpoints [RFC 4340, sec. 10]
>
> Taken together this indicates that Ack Vectors should not be disabled in the build process.
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

NAK.

Only CCID2 needs Ack vectors, CCID3 doesn't.

If we're going to tidy this up the code should be conditional on
CCID2. As I read this you're making it conditional on DCCP.

While we're at, we should turn ack vectors off by default for CCID3
(if they're built) and on for CCID2.

If you want me to come up with an alternative patch, please tell me.

Ian
-- 
Web1: http://wand.net.nz/~iam4/
Web2: http://www.jandi.co.nz
Blog: http://iansblog.jandi.co.nz
