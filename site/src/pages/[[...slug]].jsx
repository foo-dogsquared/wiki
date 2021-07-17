import { join } from 'path';
import Head from 'next/head';

import { getAllPaths, getPostBySlug } from '../lib/api';

import Link from '../components/Link';
import Rehype from '../components/Rehype';

const Note = ({ metadata, title, hast, backlinks }) => {
  const date = unquote(metadata.date);
  const date_modified = unquote(metadata.date_modified);
  return (
    <main>
      <Head>
        <title>{title}</title>
        <script src="https://polyfill.io/v3/polyfill.min.js?features=es6"></script>
        <script id="MathJax-script" async src="https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js"></script>
        <script type="text/x-mathjax-config">
                {`
                MathJax = {
                    tex: {
                        inlineMath: [ ['$','$'], ['\\(','\\)'] ],
                        displayMath: [ ['$$','$$'], ['\[','\]'] ]
                    },
                    options = {
                        processHtmlClass = "math"
                    }
                }

                console.log(MathJax)
                `}
        </script>

      </Head>
      <h1>{title}</h1>
      <section className="post-metadata">
        <span>Date: {date}</span>
        <span>Date modified: {date_modified}</span>
        {!!metadata.source &&
        (<span>Source: <a href={metadata.source}>{metadata.source}</a></span>)}
      </section>
      <Rehype hast={hast} />
      {!!backlinks.length && (
        <section>
          <h2>{'Backlinks'}</h2>
          <ul>
            {backlinks.map((b) => (
              <li key={b.path}>
                <Link href={b.path}>{b.title}</Link>
              </li>
            ))}
          </ul>
        </section>
      )}
    </main>
  );
};
export default Note;

export const getStaticPaths = async () => {
  const paths = await getAllPaths();
  // add '/' which is synonymous to '/index'
  paths.push('/');

  return {
    paths,
    fallback: false,
  };
};

function unquote(str, delimiter = '"') {
  var re = new RegExp(`${delimiter}.+${delimiter}`);
  if (str.match(re)) {
    return str.substring(1, str.length - 1);
  }

  return str;
}

export const getStaticProps = async ({ params }) => {
  const path = '/' + join(...(params.slug || ['index']));
  const post = await getPostBySlug(path);
  const data = post.data;
  const backlinks = await Promise.all([...data.backlinks].map(getPostBySlug));
  const metadata = {
      date: data.date,
      date_modified: data.date_modified,
      language: data.language,
      source: data.src || ''
  };
  console.log(data);
  return {
    props: {
      metadata,
      title: data.title || post.basename,
      hast: post.result,
      backlinks: backlinks.map((b) => ({
        path: b.path,
        title: b.data.title || b.basename,
      })),
    },
  };
};
