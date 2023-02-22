From: Eric Dumazet <edumazet@google.com>
Date: Wed, 22 Feb 2023 08:59:58 +0000
Subject: Re: [PATCH v2] net: dccp: delete redundant ackvec record in dccp_insert_options()
Message-Id: <CANn89iLT+HZKi0JtQA7HtUnMKfDSWBbZ+jeLmCH9kq+-oVxatA@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <20230222062457.630849-1-hbh25y@gmail.com>
In-Reply-To: <20230222062457.630849-1-hbh25y@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

On Wed, Feb 22, 2023 at 7:25=E2=80=AFAM Hangyu Hua <hbh25y@gmail.com> wrote:
>
> A useless record can be insert into av_records when dccp_insert_options()
> fails after dccp_insert_option_ackvec(). Repeated triggering may cause
> av_records to have a lot of useless record with the same avr_ack_seqno.

Do you have a repro for this bug ?
It is not clear if this can actually happen.
Presumably skb are sized so that they can hold all possible standard
DCCP options.
DCCP_MAX_OPT_LEN is 992 bytes.

Fact that your first patch was not even compiled is not giving us a good si=
gnal.
