From: "Arnaldo Carvalho de Melo" <arnaldo.melo@gmail.com>
Date: Sun, 26 Nov 2006 17:46:12 +0000
Subject: Re: [PATCH 4/6]: Simplify control flow of ccid3_hc_tx_send_packet
Message-Id: <39e6f6c70611260946g2b44121ex297d7687d8c88c30@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200611211545.33274@strip-the-willow>
In-Reply-To: <200611211545.33274@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 11/21/06, Ian McDonald <ian.mcdonald@jandi.co.nz> wrote:
> On 11/22/06, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> > [CCID 3]: Simplify control flow of ccid3_hc_tx_send_packet
> >
> > This makes some logically equivalent simplifications, by replacing
> > rc - values plus goto's with direct return statements.
> >
> > Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
>
> Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>

Thanks, applied.

- Arnaldo
