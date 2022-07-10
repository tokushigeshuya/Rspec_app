1	require 'rails_helper'
2	 
3	describe '投稿のテスト' do
4	  let!(:book) { create(:book,title:'hoge',body:'body') } #事前評価 itの実行時bookが出て来れば実行
5	  describe 'トップ画面(root_path)のテスト' do
6	    before do 
7	      visit root_path #指定したパスへの画面遷移
8	    end
9	    context '表示の確認' do
10	      it 'トップ画面(root_path)に一覧ページへのリンクが表示されているか' do
11	        expect(page).to have_link "", href: books_path #expect(page)で現在visitメソッドなどで開いているページ全体について調べています。
12	      end #have_linkで指定した文字列とリンクが存在するか調べている
13	      it 'root_pathが"/"であるか' do
14	        expect(current_path).to eq('/') #指定した値とexpectの値が同値であるかを判定。
15	      end
16	    end
17	  end
18	  describe "一覧画面のテスト" do
19	    before do
20	      visit books_path
21	    end
22	    context '一覧の表示とリンクの確認' do
23	      it "bookの一覧表示(tableタグ)と投稿フォームが同一画面に表示されているか" do
24	        expect(page).to have_selector 'table' #tableとHTMLで記載があるか＊タグがあるか
25	        expect(page).to have_field 'book[title]' #値のフォームが存在するか判定
26	        expect(page).to have_field 'book[body]'
27	      end
28	      it "bookのタイトルと感想を表示し、詳細・編集・削除のリンクが表示されているか" do
29	          (1..5).each do |i|
30	            Book.create(title:'hoge'+i.to_s,body:'body'+i.to_s)
31	          end
32	          visit books_path
33	          Book.all.each_with_index do |book,i|
34	            j = i * 3
35	            expect(page).to have_content book.title
36	            expect(page).to have_content book.body
37	            # Showリンク
38	            show_link = find_all('a')[j] #指定したタグを検索
39	            expect(show_link.native.inner_text).to match(/show/i) #正規表現を用いて文字列をチェック
40	            expect(show_link[:href]).to eq book_path(book)
41	            # Editリンク
42	            show_link = find_all('a')[j+1]
43	            expect(show_link.native.inner_text).to match(/edit/i)
44	            expect(show_link[:href]).to eq edit_book_path(book)
45	            # Destroyリンク
46	            show_link = find_all('a')[j+2]
47	            expect(show_link.native.inner_text).to match(/destroy/i)
48	            expect(show_link[:href]).to eq book_path(book)
49	          end
50	      end
51	      it 'Create Bookボタンが表示される' do
52	        expect(page).to have_button 'Create Book' #ボタンの存在チェック
53	      end
54	    end
55	    context '投稿処理に関するテスト' do
56	      it '投稿に成功しサクセスメッセージが表示されるか' do
57	        fill_in 'book[title]', with: Faker::Lorem.characters(number:5) #Fakerはダミー用のランダムで文字列を生成してくれる
58	        fill_in 'book[body]', with: Faker::Lorem.characters(number:20) #withの後に入力したい値を入れる
59	        click_button 'Create Book'
60	        expect(page).to have_content 'successfully'
61	      end
62	      it '投稿に失敗する' do
63	        click_button 'Create Book'
64	        expect(page).to have_content 'error'
65	        expect(current_path).to eq('/books')
66	      end
67	      it '投稿後のリダイレクト先は正しいか' do
68	        fill_in 'book[title]', with: Faker::Lorem.characters(number:5)
69	        fill_in 'book[body]', with: Faker::Lorem.characters(number:20)
70	        click_button 'Create Book'
71	        expect(page).to have_current_path book_path(Book.last)
72	      end
73	    end
74	    context 'book削除のテスト' do
75	      it 'bookの削除' do
76	        expect{ book.destroy }.to change{ Book.count }.by(-1)
77	        # ※本来はダイアログのテストまで行うがココではデータが削除されることだけをテスト
78	      end
79	    end
80	  end
81	  describe '詳細画面のテスト' do
82	    before do
83	      visit book_path(book)
84	    end
85	    context '表示の確認' do
86	      it '本のタイトルと感想が画面に表示されていること' do
87	        expect(page).to have_content book.title
88	        expect(page).to have_content book.body
89	      end
90	      it 'Editリンクが表示される' do
91	        edit_link = find_all('a')[0]
92	        expect(edit_link.native.inner_text).to match(/edit/i)
93				end
94	      it 'Backリンクが表示される' do
95	        back_link = find_all('a')[1]
96	        expect(back_link.native.inner_text).to match(/back/i)
97				end  
98	    end
99	    context 'リンクの遷移先の確認' do
100	      it 'Editの遷移先は編集画面か' do
101	        edit_link = find_all('a')[0]
102	        edit_link.click
103	        expect(current_path).to eq('/books/' + book.id.to_s + '/edit')
104	      end
105	      it 'Backの遷移先は一覧画面か' do
106	        back_link = find_all('a')[1]
107	        back_link.click
108	        expect(page).to have_current_path books_path
109	      end
110	    end
111	  end
112	  describe '編集画面のテスト' do
113	    before do
114	      visit edit_book_path(book)
115	    end
116	    context '表示の確認' do
117	      it '編集前のタイトルと感想がフォームに表示(セット)されている' do
118	        expect(page).to have_field 'book[title]', with: book.title
119	        expect(page).to have_field 'book[body]', with: book.body
120	      end
121	      it 'Update Bookボタンが表示される' do
122	        expect(page).to have_button 'Update Book'
123	      end
124	      it 'Showリンクが表示される' do
125	        show_link = find_all('a')[0]
126	        expect(show_link.native.inner_text).to match(/show/i)
127				end  
128	      it 'Backリンクが表示される' do
129	        back_link = find_all('a')[1]
130	        expect(back_link.native.inner_text).to match(/back/i)
131				end  
132	    end
133	    context 'リンクの遷移先の確認' do
134	      it 'Showの遷移先は詳細画面か' do
135	        show_link = find_all('a')[0]
136	        show_link.click
137	        expect(current_path).to eq('/books/' + book.id.to_s)
138	      end
139	      it 'Backの遷移先は一覧画面か' do
140	        back_link = find_all('a')[1]
141	        back_link.click
142	        expect(page).to have_current_path books_path
143	      end
144	    end
145	    context '更新処理に関するテスト' do
146	      it '更新に成功しサクセスメッセージが表示されるか' do
147	        fill_in 'book[title]', with: Faker::Lorem.characters(number:5)
148	        fill_in 'book[body]', with: Faker::Lorem.characters(number:20)
149	        click_button 'Update Book'
150	        expect(page).to have_content 'successfully'
151	      end
152	      it '更新に失敗しエラーメッセージが表示されるか' do
153	        fill_in 'book[title]', with: ""
154	        fill_in 'book[body]', with: ""
155	        click_button 'Update Book'
156	        expect(page).to have_content 'error'
157	      end
158	      it '更新後のリダイレクト先は正しいか' do
159	        fill_in 'book[title]', with: Faker::Lorem.characters(number:5)
160	        fill_in 'book[body]', with: Faker::Lorem.characters(number:20)
161	        click_button 'Update Book'
162	        expect(page).to have_current_path book_path(book)
163	      end
164	    end
165	  end
166	end