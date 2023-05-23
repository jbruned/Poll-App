"""
This package contains the database models and exceptions
for the Poll App
"""
from flask_sqlalchemy import SQLAlchemy
from sqlalchemy import exc
import time

db = SQLAlchemy()


class NotFoundException(Exception):
    """
    Exception thrown when a resource is not found
    """

    def __init__(self, resource_name="Resource"):
        super().__init__(f"{resource_name} not found")


class AlreadyVotedException(Exception):
    """
    Exception thrown when a user has already voted
    """

    def __init__(self):
        super().__init__("You have already voted!")


class Poll(db.Model):
    """
    Stores a ProtectedService's settings
    """
    __tablename__ = "polls"
    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(64), nullable=False)
    author = db.Column(db.String(64), nullable=True)
    timestamp = db.Column(db.DateTime, nullable=False)

    options = db.relationship(
        'Option', backref='poll', lazy=True, cascade="all, delete-orphan"
    )

    @staticmethod
    def get(poll_id: int = None):
        """
        Returns the poll with the given ID, or all the polls if no ID is given
        :param poll_id: The poll ID
        :return: The poll with the given ID, or all the polls if no ID is given
        """
        if poll_id is None:
            return Poll.query.all()
        item = Poll.query.get(poll_id)
        if item is None:
            raise NotFoundException(f"Poll #{poll_id}")
        return item

    @staticmethod
    def insert(title: str, author: str):
        """
        Adds a new poll
        @param title: The poll title
        @param author: The poll author
        """
        poll = Poll(title=title, author=author, timestamp=db.func.now())
        db.session.add(poll)
        db.session.commit()
        return poll

    def delete(self):
        """
        Deletes the poll
        """
        db.session.delete(self)
        db.session.commit()

    def update(self, title: str):
        """
        Updates the poll data
        @param title: The poll title
        """
        self.title = title
        db.session.commit()

    def get_options(self):
        """
        Returns the options for the poll
        """
        return Option.query.filter_by(poll_id=self.id).all()

    def get_answers_count(self):
        """
        Returns the number of answers for the poll
        """
        return Answer.query \
            .join(Option, Option.id == Answer.option_id) \
            .filter(Option.poll_id == self.id).count()

    def get_answers_count_by_option(self):
        """
        Returns the number of answers for each option of the poll
        """
        return db.session.query(Option.id, db.func.count(Answer.id)) \
            .join(Option, Option.id == Answer.option_id) \
            .filter(Option.poll_id == self.id) \
            .group_by(Option.id).all()

    def has_answered(self, current_session_id: str):
        """
        Returns True if the poll has been answered by the given session ID
        @param current_session_id: The user session ID
        """
        return db.session.query(Answer).join(Option).filter(
            Option.poll_id == self.id, Answer.session_id == current_session_id
        ).count() > 0

    def get_answer(self, current_session_id: str):
        """
        Returns the answer of the user with the given session ID
        @param current_session_id: The user session ID
        """
        return db.session.query(Answer).join(Option).filter(
            Option.poll_id == self.id, Answer.session_id == current_session_id
        ).first()

    def get_answered_option(self, session_id: str):
        """
        Returns the answer option of the user with the given session ID
        @param session_id: The user session ID
        @return: The answer option of the user with the given session ID
                 if the user has already voted, None otherwise
        """
        answer = self.get_answer(session_id)
        if answer is None:
            return None
        item = Option.query.get(answer.option_id)
        if item is None:
            raise NotFoundException("Answered option")
        return item

    @staticmethod
    def get_polls(as_dict: bool = False):
        """
        Returns a list with all the polls including:
            - the id
            - the title
            - the author
            - the timestamp
            - the option count
            - the answer count
        """
        polls = Poll.query.all()
        return polls if not as_dict else [poll.get_info() for poll in polls]

    def get_info(self, session_id=None):
        """
        Returns a dictionary with the poll info
        """
        options = [option.to_dict() for option in self.get_options()]
        return {
            'id': self.id,
            'title': self.title,
            'author': self.author,
            'timestamp': self.timestamp,
            'options': options,
            'options_count': len(options),
            'answers_count': self.get_answers_count(),
            'answers_count_by_option': self.get_answers_count_by_option(),
            'user_answered': self.get_answered_option(session_id)
            if session_id is not None else False
        }


class Option(db.Model):
    """
    Stores a login attempt from an IP and a ProtectedService
    """
    __tablename__ = "options"
    id = db.Column(db.Integer, primary_key=True)
    poll_id = db.Column(
        db.Integer,
        db.ForeignKey('polls.id', ondelete='CASCADE'),
        nullable=False
    )
    text = db.Column(db.String(64), nullable=False)

    answers = db.relationship(
        'Answer', backref='option', lazy=True, cascade="all, delete-orphan"
    )

    @staticmethod
    def get(option_id: int):
        """
        Returns the option with the given ID
        :param option_id: The option ID
        :return: The option with the given ID
        """
        item = Option.query.get(option_id)
        if item is None:
            raise NotFoundException(f"Option #{option_id}")
        return item

    @staticmethod
    def insert(poll_id: int, text: str):
        """
        Adds a new option for the poll with the given ID
        @param poll_id: The poll ID
        @param text: The option text
        """
        option = Option(poll_id=poll_id, text=text)
        db.session.add(option)
        db.session.commit()
        return option

    def delete(self):
        """
        Deletes the option
        """
        db.session.delete(self)
        db.session.commit()

    def update(self, text: str):
        """
        Updates the option data
        @param text: The option text
        """
        self.text = text
        db.session.commit()

    def get_poll(self):
        """
        Returns the poll for the option
        """
        return Poll.get(self.poll_id)

    def vote(self, session_id: str):
        """
        Adds a new answer for the option
        @:param session_id: The user session ID
        @:return The answer object if the user has not already voted
        @:raises AlreadyVotedException if the user has already voted
        """
        if self.get_poll().has_answered(session_id):
            raise AlreadyVotedException()
        answer = Answer(
            option_id=self.id,
            session_id=session_id,
            timestamp=db.func.now()
        )
        db.session.add(answer)
        db.session.commit()
        return answer

    def to_dict(self):
        """
        Returns a dictionary with the option info
        """
        return {
            'id': self.id,
            'text': self.text,
            'answers_count': self.get_answers_count()
        }

    def get_answers_count(self):
        """
        Returns the number of answers for the option
        """
        return db.session.query(Answer).filter(
            Answer.option_id == self.id
        ).count()

    def remove_vote(self, current_session_id: str):
        """
        Removes the vote from the poll option
        @param current_session_id: The user session ID
        """
        Answer.query.filter(
            Answer.option_id == self.id, Answer.session_id == current_session_id
        ).delete()


class Answer(db.Model):  # pylint: disable=too-few-public-methods
    """
    Stores an answer for a poll
    """
    __tablename__ = "answers"
    id = db.Column(db.Integer, primary_key=True)
    option_id = db.Column(
        db.Integer,
        db.ForeignKey('options.id', ondelete='CASCADE'),
        nullable=False
    )
    session_id = db.Column(db.String(64), nullable=False)
    timestamp = db.Column(db.DateTime, nullable=False)

    def delete(self):
        """
        Deletes the answer
        """
        db.session.delete(self)
        db.session.commit()


def insert_test_data():
    """
    Inserts some test data into the database
    """
    poll = Poll.insert(title="Test poll", author="Admin")
    Option.insert(text="Option A", poll_id=poll.id)
    Option.insert(text="Option B", poll_id=poll.id)

    poll = Poll.insert(title="When do you prefer this course's exam?",
                       author="Admin")
    Option.insert(text="May 17th", poll_id=poll.id)
    Option.insert(text="May 31st", poll_id=poll.id)

    poll = Poll.insert(title="Another poll",
                       author="Jorge Bruned")
    option = Option.insert(text="Option 1", poll_id=poll.id)
    Option.insert(text="Option 2", poll_id=poll.id)
    Option.insert(text="Option 3", poll_id=poll.id)
    Option.insert(text="Option 4", poll_id=poll.id)
    Option.insert(text="Option 5", poll_id=poll.id)
    option.vote("test")

    poll = Poll.insert(title="Poll with a single option",
                       author="Unai Biurrun")
    Option.insert(text="Not much to choose from, right?", poll_id=poll.id)

    poll = Poll.insert(title="Yet another poll", author="Iñaki Velasco")
    Option.insert(text="Option 1", poll_id=poll.id)
    Option.insert(text="Option 2", poll_id=poll.id)
    Option.insert(text="Option 3", poll_id=poll.id)
    Option.insert(text="All of the above", poll_id=poll.id)

def handle_database_reconnect(max_retries: int = 5, retry_interval: int = 5):
    """
    Tries to reconnect to the database
    """
    retries = 0
    while retries < max_retries:
        try:
            db.session.rollback()
            db.session.close()
            db.engine.dispose()
            db.create_all()
            print("Database reconnected successfully!")
            return
        except exc.SQLAlchemyError:
            retries += 1
            time.sleep(retry_interval)
            
    print("Unable to reconnect to the database after maximum retries.")

