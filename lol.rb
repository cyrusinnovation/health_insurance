require 'docsplit'

docs = Dir['*.pdf']

Docsplit.extract_text(docs, :ocr => false, :output => 'storage/text')
