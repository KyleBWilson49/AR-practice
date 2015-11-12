# == Schema Information
#
# Table name: questions
#
#  id         :integer          not null, primary key
#  poll_id    :integer
#  text       :string
#  created_at :datetime
#  updated_at :datetime
#

class Question < ActiveRecord::Base
  validates :text, presence: true, uniqueness: true
  validates :poll_id, presence: true

  has_many :answer_choices,
    foreign_key: :question_id,
    primary_key: :id,
    class_name: "AnswerChoice"

  belongs_to :poll,
    foreign_key: :poll_id,
    primary_key: :id,
    class_name: "Poll"

  has_many :responses,
    through: :answer_choices,
    source: :responses

  def results
    # choices = answer_choices.includes(:responses)
    # p "test"
    results = {}
    # choices.each do |choice|
    #   results[choice.choice] = choice.responses.length
    # end
    # results
    choices = AnswerChoice.find_by_sql([<<-SQL, id])
      SELECT
        answer_choices.choice,
        COUNT(responses.user_id) as total
      FROM
        answer_choices
      LEFT OUTER JOIN
        responses ON answer_choices.id = responses.answer_choice_id
      WHERE
        answer_choices.question_id = ?
      GROUP BY
        answer_choices.choice
    SQL

    choices.each do |choice|
      results[choice.choice] = choice.total
    end

    results
  end
end
