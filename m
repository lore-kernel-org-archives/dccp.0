From: "Arnaldo Carvalho de Melo" <arnaldo.melo@gmail.com>
Date: Fri, 01 Dec 2006 13:43:37 +0000
Subject: Re: [PATCHv2] [DCCP]: Use higher timeout value for nofeedback timer
Message-Id: <39e6f6c70612010543t144e465bn6907eec071699fa2@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200612011314.26835@strip-the-willow>
In-Reply-To: <200612011314.26835@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 12/1/06, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> Quoting Arnaldo Carvalho de Melo:
> |  We're agreeing Gerrit... you jumped to conclusions too fast because
> |  you didn't read what I said in the next paragraph, that I quote here:
> |
> |  ------------------------
> |  Clarification on this one, you had _fixed_ it in your previous patch,
> |  then removed this bit :)
> |  ------------------------
> Oh, I apologise.
>
> I just got an email from Colin Perkins (do you read dccp@ietf?) who says
> that it should be 16..20msec. I think will change to milliseconds, use the
> default of 100msec suggested by Mark Handley, and update the configuration
> menu once again.

Yes, I do, saw that message :-)

- Arnaldo
