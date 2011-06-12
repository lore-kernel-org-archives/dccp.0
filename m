From: Ivo Calado <ivo.calado@ee.ufcg.edu.br>
Date: Sun, 12 Jun 2011 13:12:43 +0000
Subject: Doubt about DCCP_SOCKOPT_GET_CUR_MPS
Message-Id: <BANLkTikMe4KHb1tDvb7_XCsvwsLvvqN=1w@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Hi guys, I'm dealing with a doubt to retrieve the current PMTU. I'm
calling the getsockopt syscall with DCCP_SOCKOPT_GET_CUR_MPS option. I
tried such operation in both sides with the socket opened. however,
I'm always getting the same value: 0.  I'm running this in loopback
interface.
     Is that right for such network interface?

Regards
[]'s

--
Ivo Calado
PhD candidate in Electrical Engineering
Embedded Systems and Pervasive Computing Lab - http://embeddedlab.org
Electrical Engineering Department - http://dee.ufcg.edu.br/
Federal University of Campina Grande - http://www.ufcg.edu.br
Professor of the Federal Institute of Education, Science and
Technology of Alagoas - http://ifal.edu.br

PGP: 0xD7C3860A pgp.mit.edu
Putt's Law:
=A0 =A0 =A0=A0 Technology is dominated by two types of people:
=A0 =A0 =A0 =A0 =A0 =A0 =A0=A0 Those who understand what they do not manage.
=A0 =A0 =A0 =A0 =A0 =A0 =A0=A0 Those who manage what they do not understand.
