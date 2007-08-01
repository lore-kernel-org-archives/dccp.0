From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Wed, 01 Aug 2007 22:12:26 +0000
Subject: Re: RFD: Ack Vectors
Message-Id: <5640c7e00708011512p7558cfaflaf9813fd4b088715@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200707300934.36798@strip-the-willow>
In-Reply-To: <200707300934.36798@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 8/2/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> Omission on my side - I have just checked and found out that the negotiation of the "Send ack vector
> feature" is not yet implemented. It is not something which can be done with a hack, since the CCIDs
> can also be negotiated, so that enabling Ack Vectors depends on the end result of negotiating the
> CCID.
> I think at the moment we should add this as a ToDo. If I get some time I'll try to implement the
> above, but it is more work than anticipated and so depends on available time.
>

Well I think the discussion is useful as a future reference. There's
no hurry on any of this really.

> |  The information is not actually needed from an ack vector
> |  and actually creates more traffic. It seems like
> |  draft-kohler-dccp-ccid3-drops-01.txt is a replacement for ack vectors
> |  in CCID3 if you need extra info.
> Never figured that one out - doesn't the Data Dropped option do the same thing?
>
Data Dropped is more when receiver gets it but discards for some
reason as I read it.

Ian
-- 
Web1: http://wand.net.nz/~iam4/
Web2: http://www.jandi.co.nz
Blog: http://iansblog.jandi.co.nz
