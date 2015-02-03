#!perl -T

use Test::Most import => ['!pass'];
use Plack::Test;
use HTTP::Request::Common;
use feature qw(fc);

sub isfc   { is fc(shift),   fc(shift), shift; }
sub isntfc { isnt fc(shift), fc(shift), shift; }

{

    package Webservice;
    use Dancer2;
    use Dancer2::Plugin::Negotiate;

    get '/' => sub {
        apply_variant(
            var1 => {
                Quality  => 1.000,
                Type     => 'text/html',
                Charset  => 'iso-8859-1',
                Language => 'en'
            },
            var2 => {
                Quality  => 0.950,
                Type     => 'text/plain',
                Charset  => 'us-ascii',
                Language => 'no'
            },
        );
    };

}

my $PT = Plack::Test->create( Webservice->to_app );

plan tests => 2;

subtest var1 => sub {
    plan tests => 5;
    my $R = $PT->request( GET('/') );
    ok $R->is_success;
    isfc $R->content                         => 'var1';
    like $R->header( fc 'Content-Type' )     => qr'^text/html(\s*;.*)?$';
    isfc $R->header( fc 'Content-Charset' )  => 'iso-8859-1';
    isfc $R->header( fc 'Content-Language' ) => 'en';
};

subtest var2 => sub {
    plan tests => 5;
    my $R = $PT->request( GET( '/', Accept => 'text/plain' ) );
    ok $R->is_success;
    isfc $R->content                         => 'var2';
    like $R->header( fc 'Content-Type' )     => qr'^text/plain(\s*;.*)?$';
    isfc $R->header( fc 'Content-Charset' )  => 'us-ascii';
    isfc $R->header( fc 'Content-Language' ) => 'no';
};

done_testing;
